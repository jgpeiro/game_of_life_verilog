
import os
import time
import subprocess
import argparse

#python file_monitor.py -f spi_slave.v -f spi_slave_tb.v -t 0.1


def parse_arguments():
    parser = argparse.ArgumentParser(description="Monitor files for changes and run a command when changes occur.")
    parser.add_argument("-f", "--file", action="append", required=True, help="File(s) to monitor for changes.")
    parser.add_argument("-t", "--interval", type=float, default=1.0, help="Interval (in seconds) to check for file changes.")
    return parser.parse_args()

def run_gtkwave(filename):
    cmd = f"gtkwave -f {filename}"
    print( cmd )
    subprocess.Popen( cmd )


def main():
    args = parse_arguments()

    # Files to monitor
    files_to_watch = args.file
    
    input_tb_file = ""
    for file in files_to_watch:
        if( "tb" in file ):
            input_tb_file = file
            break
    
    output_iv_file = input_tb_file.replace(".v", ".iv")
    output_vcd_file = input_tb_file.replace(".v", ".vcd")
    

    print( time.strftime("%Y-%m-%d %H:%M:%S" ) )
    
    # Command to execute
    command1_to_run = f"iverilog -o {output_iv_file} {' '.join(files_to_watch)}"
    command2_to_run = f"vvp {output_iv_file}"
    
    # Get initial timestamps of the files
    file_timestamps = {file: os.path.getmtime(file) for file in files_to_watch}
    
    print( command1_to_run )
    subprocess.run(command1_to_run, shell=True)
    print( command2_to_run )
    subprocess.run(command2_to_run, shell=True)
    print( "gtkwave" )
    run_gtkwave( output_vcd_file )
    
    # Infinite loop to continuously monitor files
    while True:
        # Check for changes in file timestamps
        for file in files_to_watch:
            current_timestamp = os.path.getmtime(file)
            if current_timestamp != file_timestamps[file]:
                print( time.strftime("%Y-%m-%d %H:%M:%S" ) )
                print(f"File '{file}' has been updated. Running the command...", command1_to_run )
                subprocess.run(command1_to_run, shell=True)
                print(f"File '{file}' has been updated. Running the command...", command2_to_run )
                subprocess.run(command2_to_run, shell=True)
                # Update the timestamp for the file
                file_timestamps[file] = current_timestamp
                print( "" )
        
        # Sleep for a while before checking again (adjust the delay as needed)
        time.sleep(args.interval)

if __name__ == "__main__":
    main()
