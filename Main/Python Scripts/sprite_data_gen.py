import getopt
import sys
from helpers.helpers import Helper


def add_data(data, string):
    data += string
    return data


def process(line, outfile):
    data = ''
    func = line.split('(')
    if func[0] != 'Sprite':
        return False
    args = func[1].split(')')
    args = args[0].split(',')

    if len(args) != 10:
        return False

    # Active
    if args[0] == 'true':
        data = add_data(data, '1')
    elif args[1] == 'false':
        data = add_data(data, '0')
    else:
        return False

    # Moving
    if args[1] == 'true':
        data = add_data(data, '1')
    elif args[1] == 'false':
        data = add_data(data, '0')
    else:
        return False

    # Direction
    if args[2] == 'up':
        data = add_data(data, '00')
    elif args[2] == 'down':
        data = add_data(data, '01')
    elif args[2] == 'left':
        data = add_data(data, '10')
    elif args[2] == 'right':
        data = add_data(data, '11')
    else:
        return False

    # Blank Space
    data = add_data(data, Helper.pad(bin(int(0))[2:], 4))

    # X Coordinate
    data = add_data(data, Helper.pad(bin(int(args[3]))[2:], 8))

    # Y Coordinate
    data = add_data(data, Helper.pad(bin(int(args[4]))[2:], 8))

    # Distance
    data = add_data(data, Helper.pad(bin(int(args[5]))[2:], 8))

    # Speed
    data = add_data(data, Helper.pad(bin(int(args[6]))[2:], 8))

    #  Image Select
    data = add_data(data, Helper.pad(bin(int(args[7]))[2:], 8))

    # Health
    data = add_data(data, Helper.pad(bin(int(args[8]))[2:], 8))

    # Lives
    data = add_data(data, Helper.pad(bin(int(args[9]))[2:], 8))

    outfile.write(data + ',\n')


def main(argv):
    input_file = ''
    output_file = 'generated_coe/sprite_data_gen.coe'
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
        if process(line, o):
            print 'Error @ line ' + str(line_counter)
        line_counter += 1

    for x in range(0, 256 - (line_counter+1)):
        o.write(Helper.pad("0", 64) + ",\n")

    o.write(Helper.pad("0", 64) + ";")

    f.close()
    o.close()


if __name__ == "__main__":
    main(sys.argv[1:])
