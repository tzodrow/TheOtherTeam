import getopt
import sys


def main(argv):
    print "This started"
    inputfile = ''
    outputfile = ''
    try:
        opts, args = getopt.getopt(argv, "hi:o:", ["ifile=", "ofile="])
    except getopt.GetoptError:
        print 'test.py -i <inputfile> -o <outputfile>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-help':
            print 'test.py -i <inputfile> -o <outputfile>'
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputfile = arg
        elif opt in ("-o", "--ofile"):
            outputfile = arg

    f = open(inputfile, 'r')
    o = open(outputfile, 'w')

    print "Starting..."

    red = 'ff0000,\n'
    green = '008000,\n'
    blue = '0000ff,\n'
    white = 'ffffff,\n'

    o.write("memory_initialization_radix=16;\n")
    o.write("memory_initialization_vector=\n")

    for x in range(0, 76800):
        if x % 4 == 0:
            o.write(red)
        elif x % 4 == 1:
            o.write(green)
        elif x % 4 == 2:
            o.write(blue)
        else:
            o.write(white)

    print "Done!"

    f.close()
    o.close()


if __name__ == "__main__":
    main(sys.argv[1:])