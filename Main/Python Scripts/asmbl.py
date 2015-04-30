import getopt
import sys
from helpers.assembly_functions import Function
from helpers.helpers import Helper


def main(argv):
    input_file = ''
    output_file = 'generated_coe/instruction_rom.coe'
    try:
        opts, args = getopt.getopt(argv, "hi:", ["ifile="])
    except getopt.GetoptError:
        print 'test.py -i <inputfile>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-help':
            print 'test.py -i <input_file>'
            sys.exit()
        elif opt in ("-i", "--ifile"):
            input_file = arg

    f = open(input_file, 'r')
    o = open(output_file, 'w')

    o.write("memory_initialization_radix=2;\n")
    o.write("memory_initialization_vector=\n")

    line_counter = 0
    for line in f:
        if not Function.is_comment(line):
            Function.find_labels(line, line_counter)
            line_counter += 1
    f.close()

    f = open(input_file, 'r')
    line_counter = 0
    for line in f:
        Function.process(line, o, line_counter)
        line_counter += 1

    for x in range(0, 131072 - line_counter - 1):
        o.write(Helper.pad("0", 32) + ",\n")

    o.write(Helper.pad("0", 32) + ";")

    f.close()
    o.close()


if __name__ == "__main__":
    main(sys.argv[1:])