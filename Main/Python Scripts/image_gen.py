from helpers.constants import Constants
from helpers.draw_image_functions import Pacman, Ghost

__author__ = 'tzodrow'


def main():
    print "Generating COE File..."

    o = open('generated_coe/image_rom.coe', 'w')

    o.write("memory_initialization_radix=16;\n")
    o.write("memory_initialization_vector=\n")

    num_images = 9

    # Image Order in Memory
    Pacman.draw_pacman_up(o)
    Pacman.draw_pacman_down(o)
    Pacman.draw_pacman_left(o)
    Pacman.draw_pacman_right(o)

    Ghost.create(o, Constants.color['green'])
    Ghost.create(o, Constants.color['orange'])
    Ghost.create(o, Constants.color['red'])
    Ghost.create(o, Constants.color['purple'])
    Ghost.create(o, Constants.color['light_blue'])



    for x in range(0, (256 - num_images) * 64 - 1):
        o.write(Constants.color['black'])

    o.write(Constants.color['end'])

    print "Done!"
    o.close()


if __name__ == "__main__":
    main()
