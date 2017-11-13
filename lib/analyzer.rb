require 'erb'
require 'json'
require 'tmpdir'

class Analyzer
  
  def initialize(*test_files, bootstrap: nil, lib: nil, n: nil)
    @bootstrap = bootstrap
    @lib = lib
    @n = n
    @test_files = test_files
  end
  
  def key(value)
    File.basename(value, ".*")
  end
  
  def tests
    @test_files.map{ |f| key(f) }
  end
  
  def bootstrap
    if @bootstrap
      system("ruby", "-r", "#{File.expand_path(@lib)}", File.expand_path(@bootstrap))
      if $?.exitstatus > 0
        exit 1
      end
    end
  end

  def write_results_for(type, dir)
    Dir.mkdir(File.join(dir, type))
    @test_files.each do |src|
      File.open(File.join(dir, type, key(src)), 'w') do |file|
        send(:"output_#{type}_results", calculate_results_for(type, File.read(src)), file)
      end
    end
  end

  def calculate_results_for(type, src)
    lib = @lib ? File.read(File.expand_path(@lib)) : ''
    
    if src.index("\n__SETUP__\n")
      src = src.split("\n__SETUP__\n")
      setup = src[0]
      src = src[1]
    else
      setup = ''
    end
    
    analyzer_dir = File.expand_path("../", __FILE__)
    template = File.read(File.expand_path("../templates/#{type}.rb.erb", __FILE__))
    _script = ''
    ERB.new(template, nil, nil, "_script").result(binding)
    results = `ruby <<'TESTSCRIPT'\n#{_script}\nTESTSCRIPT`
  
    if $? == 0
      JSON.parse(results)
    else
      puts results
      exit
    end
  end
  
  def output_ips_results(results, output)
    output.write(results.join("\n"))
  end
  
  def output_gc_results(results, output)
    last_row = results.shift
    first_row = last_row
    results.each do |row|
      output.puts [row[0], row[0] - first_row[0], row[1], row[2], row[1] - last_row[1], row[2] - last_row[2], row[3], row[4], row[3] - last_row[3], row[4] - last_row[4]].join(' ')
      last_row = row
    end
  end

  def output_rss_results(results, output)
    last_row = results.shift
    first_row = last_row
    results.each do |row|
      output.puts [row[0], row[0] - first_row[0], row[1], row[1] - last_row[1]].join(' ')
      last_row = row
    end
  end

  def escape(value)
    value.gsub('_', '\\\\_')
  end
  
  def plot(output)
    Dir.mktmpdir do |dir|
      write_results_for('ips', dir)
      write_results_for('gc', dir)
      write_results_for('rss', dir)
      
      template = File.read(File.expand_path('../templates/gnuplot.sh.erb', __FILE__))
      _script = ''
      data_dir = dir
      ERB.new(template, nil, nil, "_script").result(binding)
      `gnuplot <<-GNUPLOT\n#{_script}\nGNUPLOT`
    end
  end

  # ttfb
  # ttlb
end