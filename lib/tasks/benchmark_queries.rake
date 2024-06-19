namespace :benchmark do
  desc "Run SQL query benchmarks"
  task queries: :environment do
    require 'benchmark'
    require 'benchmark/ips'
    require 'logger'
    logger = Logger.new(STDOUT)

    logger.info "Starting benchmark queries..."

    def display_results(title, results)
      puts "\n--- #{title} ---"
      results.each do |label, time|
        puts "#{label.ljust(30)}: #{time.real.round(4)} seconds"
      end
      puts "-----------------------\n\n"
    end

    Benchmark.bm do |x|
      # Example 1: Simple Query
      bad_result, good_result = nil

      # Bad: N+1 Query
      x.report("Simple Query (Bad)") do
        logger.info "Running Simple Query (Bad)..."
        logger.info "SQL: SELECT * FROM artists;"
        logger.info "SQL: SELECT * FROM albums WHERE artist_id = ?;"
        bad_result = Benchmark.measure do
          Artist.all.each do |artist|
            artist.albums.to_a
          end
        end
        logger.info "Completed Simple Query (Bad)"
      end

      # Good: Eager Loading
      x.report("Simple Query (Good)") do
        logger.info "Running Simple Query (Good)..."
        logger.info "SQL: SELECT * FROM artists LEFT OUTER JOIN albums ON albums.artist_id = artists.id;"
        good_result = Benchmark.measure do
          Artist.includes(:albums).all.to_a
        end
        logger.info "Completed Simple Query (Good)"
      end

      display_results("Simple Query", { "Bad" => bad_result, "Good" => good_result })

      # Example 2: Complex Join Query
      bad_result, good_result = nil

      # Bad: No Index on Join
      x.report("Complex Join Query (Bad)") do
        logger.info "Running Complex Join Query (Bad)..."
        logger.info "SQL: SELECT artists.name, albums.title, tracks.name AS track_name, tracks.unit_price"
        logger.info "SQL: FROM artists"
        logger.info "SQL: INNER JOIN albums ON albums.artist_id = artists.id"
        logger.info "SQL: INNER JOIN tracks ON tracks.album_id = albums.id"
        logger.info "SQL: WHERE tracks.unit_price > 1.0;"
        bad_result = Benchmark.measure do
          Artist.joins(albums: :tracks)
                .where('tracks.unit_price > ?', 1.0)
                .select('artists.name, albums.title, tracks.name AS track_name, tracks.unit_price')
                .to_a
        end
        logger.info "Completed Complex Join Query (Bad)"
      end

      # Good: Index on Join Columns
      x.report("Complex Join Query (Good)") do
        logger.info "Running Complex Join Query (Good)..."
        ActiveRecord::Base.connection.execute("CREATE INDEX IF NOT EXISTS index_tracks_on_unit_price ON tracks (unit_price);")
        logger.info "SQL: SELECT artists.name, albums.title, tracks.name AS track_name, tracks.unit_price"
        logger.info "SQL: FROM artists"
        logger.info "SQL: INNER JOIN albums ON albums.artist_id = artists.id"
        logger.info "SQL: INNER JOIN tracks ON tracks.album_id = albums.id"
        logger.info "SQL: WHERE tracks.unit_price > 1.0;"
        good_result = Benchmark.measure do
          Artist.joins(albums: :tracks)
                .where('tracks.unit_price > ?', 1.0)
                .select('artists.name, albums.title, tracks.name AS track_name, tracks.unit_price')
                .to_a
        end
        logger.info "Completed Complex Join Query (Good)"
      end

      display_results("Complex Join Query", { "Bad" => bad_result, "Good" => good_result })

      # Example 3: Aggregate Function Query
      bad_result, good_result = nil

      # Bad: No Index on Group By
      x.report("Aggregate Function Query (Bad)") do
        logger.info "Running Aggregate Function Query (Bad)..."
        logger.info "SQL: SELECT customer_id, SUM(total) as total_spent"
        logger.info "SQL: FROM invoices"
        logger.info "SQL: GROUP BY customer_id"
        logger.info "SQL: HAVING SUM(total) > 50;"
        bad_result = Benchmark.measure do
          Invoice.select('customer_id, SUM(total) as total_spent')
                 .group(:customer_id)
                 .having('SUM(total) > ?', 50)
                 .to_a
        end
        logger.info "Completed Aggregate Function Query (Bad)"
      end

      # Good: Index on Group By Column
      x.report("Aggregate Function Query (Good)") do
        logger.info "Running Aggregate Function Query (Good)..."
        ActiveRecord::Base.connection.execute("CREATE INDEX IF NOT EXISTS index_invoices_on_customer_id ON invoices (customer_id);")
        logger.info "SQL: SELECT customer_id, SUM(total) as total_spent"
        logger.info "SQL: FROM invoices"
        logger.info "SQL: GROUP BY customer_id"
        logger.info "SQL: HAVING SUM(total) > 50;"
        good_result = Benchmark.measure do
          Invoice.select('customer_id, SUM(total) as total_spent')
                 .group(:customer_id)
                 .having('SUM(total) > ?', 50)
                 .to_a
        end
        logger.info "Completed Aggregate Function Query (Good)"
      end

      display_results("Aggregate Function Query", { "Bad" => bad_result, "Good" => good_result })

      # Example 4: Window Function Query
      bad_result, good_result = nil

      # Bad: Window Function without Partitioning
      x.report("Window Function Query (Bad)") do
        logger.info "Running Window Function Query (Bad)..."
        logger.info "SQL: SELECT customer_id, invoice_date, total,"
        logger.info "SQL:        SUM(total) OVER (ORDER BY invoice_date) AS running_total"
        logger.info "SQL: FROM invoices;"
        bad_result = Benchmark.measure do
          ActiveRecord::Base.connection.execute(<<-SQL).to_a
            SELECT customer_id, invoice_date, total,
                   SUM(total) OVER (ORDER BY invoice_date) AS running_total
            FROM invoices
          SQL
        end
        logger.info "Completed Window Function Query (Bad)"
      end

      # Good: Window Function with Partitioning
      x.report("Window Function Query (Good)") do
        logger.info "Running Window Function Query (Good)..."
        logger.info "SQL: SELECT customer_id, invoice_date, total,"
        logger.info "SQL:        SUM(total) OVER (PARTITION BY customer_id ORDER BY invoice_date) AS running_total"
        logger.info "SQL: FROM invoices;"
        good_result = Benchmark.measure do
          ActiveRecord::Base.connection.execute(<<-SQL).to_a
            SELECT customer_id, invoice_date, total,
                   SUM(total) OVER (PARTITION BY customer_id ORDER BY invoice_date) AS running_total
            FROM invoices
          SQL
        end
        logger.info "Completed Window Function Query (Good)"
      end

      display_results("Window Function Query", { "Bad" => bad_result, "Good" => good_result })

      # Example 5: Trigger Example
      bad_result, good_result = nil

      # Bad: Trigger without Optimization
      x.report("Trigger Function Query (Bad)") do
        logger.info "Setting up Trigger Function (Bad)..."
        logger.info "SQL: CREATE OR REPLACE FUNCTION update_invoice_total_bad() RETURNS TRIGGER AS $$"
        logger.info "SQL: BEGIN"
        logger.info "SQL:   NEW.total := (SELECT SUM(quantity * unit_price) FROM invoice_lines WHERE invoice_id = NEW.id);"
        logger.info "SQL:   RETURN NEW;"
        logger.info "SQL: END;"
        logger.info "SQL: $$ LANGUAGE plpgsql;"
        ActiveRecord::Base.connection.execute(<<-SQL)
          CREATE OR REPLACE FUNCTION update_invoice_total_bad() RETURNS TRIGGER AS $$
          BEGIN
            NEW.total := (SELECT SUM(quantity * unit_price) FROM invoice_lines WHERE invoice_id = NEW.id);
            RETURN NEW;
          END;
          $$ LANGUAGE plpgsql;

          DROP TRIGGER IF EXISTS update_invoice_total_trigger_bad ON invoices;
          CREATE TRIGGER update_invoice_total_trigger_bad
          BEFORE INSERT OR UPDATE ON invoices
          FOR EACH ROW EXECUTE FUNCTION update_invoice_total_bad();
        SQL
        logger.info "Running Trigger Function Query (Bad)..."
        bad_result = Benchmark.measure do
          Invoice.update_all(invoice_date: Date.today)
        end
        logger.info "Completed Trigger Function Query (Bad)"
      end

      # Good: Optimized Trigger with Partial Index
      x.report("Trigger Function Query (Good)") do
        logger.info "Setting up Trigger Function (Good)..."
        logger.info "SQL: CREATE OR REPLACE FUNCTION update_invoice_total_good() RETURNS TRIGGER AS $$"
        logger.info "SQL: BEGIN"
        logger.info "SQL:   NEW.total := (SELECT SUM(quantity * unit_price) FROM invoice_lines WHERE invoice_id = NEW.id);"
        logger.info "SQL:   RETURN NEW;"
        logger.info "SQL: END;"
        logger.info "SQL: $$ LANGUAGE plpgsql;"
        ActiveRecord::Base.connection.execute(<<-SQL)
          CREATE OR REPLACE FUNCTION update_invoice_total_good() RETURNS TRIGGER AS $$
          BEGIN
            NEW.total := (SELECT SUM(quantity * unit_price) FROM invoice_lines WHERE invoice_id = NEW.id);
            RETURN NEW;
          END;
          $$ LANGUAGE plpgsql;

          DROP TRIGGER IF EXISTS update_invoice_total_trigger_good ON invoices;
          CREATE TRIGGER update_invoice_total_trigger_good
          BEFORE INSERT OR UPDATE ON invoices
          FOR EACH ROW EXECUTE FUNCTION update_invoice_total_good();
        SQL
        logger.info "Running Trigger Function Query (Good)..."
        good_result = Benchmark.measure do
          Invoice.update_all(invoice_date: Date.today)
        end
        logger.info "Completed Trigger Function Query (Good)"
      end

      display_results("Trigger Function Query", { "Bad" => bad_result, "Good" => good_result })
    end

    logger.info "Benchmark queries completed."
  end
end
