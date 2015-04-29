import getopt
import sys

__author__ = 'tzodrow'

color = dict(
    red='ff0000,\n',
    green='008000,\n',
    blue='0000ff,\n',
    white='ffffff,\n',
    black='000000,\n',
    yellow='ffff00,\n'
)


# Draw the Up Facing PacMan
def draw_pacman_up(outfile):
    # First Line
    for x in range(0, 8):
        if x < 2 or x == 7:
            outfile.write(color['black'])
        else:
            outfile.write(color['yellow'])

    # Second Line
    for x in range(0, 8):
        if x == 0 or x > 5:
            outfile.write(color['black'])
        else:
            outfile.write(color['yellow'])

    # Third Line
    for x in range(0, 8):
        if x > 4:
            outfile.write(color['black'])
        else:
            outfile.write(color['yellow'])

    # Forth Line
    for x in range(0, 8):
        if x > 3:
            outfile.write(color['black'])
        else:
            outfile.write(color['yellow'])

    # Fifth Line
    for x in range(0, 8):
        if x > 3:
            outfile.write(color['black'])
        else:
            outfile.write(color['yellow'])

    # Sixth Line
    for x in range(0, 8):
        if x > 4:
            outfile.write(color['black'])
        else:
            outfile.write(color['yellow'])

    # Seventh Line
    for x in range(0, 8):
        if x == 0 or x > 5:
            outfile.write(color['black'])
        else:
            outfile.write(color['yellow'])

    # Eighth Line
    for x in range(0, 8):
        if x < 2 or x == 7:
            outfile.write(color['black'])
        else:
            outfile.write(color['yellow'])


def main(argv):
    print "Generating COE File..."
    o = open('image_rom.coe', 'w')

    o.write("memory_initialization_radix=16;\n")
    o.write("memory_initialization_vector=\n")

    draw_pacman_up(o)

    print "Done!"
    o.close()


if __name__ == "__main__":
    main(sys.argv[1:])
