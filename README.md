# vdj-recombination

Source code for the VDJ visualization used in [a VDJ recombination video](https://www.youtube.com/watch?v=3qvfjdZs8Yc).

To run, download [Processing 3.5.4](https://processing.org/releases) and install it. In Processing 3, download the Video Export 0.2.3 library by Abe Pazos, which can be found by searching "hamoid" in File > Import Library > Add Library [(also here)](https://funprogramming.org/VideoExport-for-Processing). The library will require you to install ffmpeg, instructions for that will be given on the first time you run the program. Open ievan.pde and press play. Warning: Processing 4 will NOT work.

For sake of coding simplicity (because this was created in a time-constrained environment), Ka values don’t have a truly random logarithmic distribution, all mutations are depicted to affect Ka even though only those in the binding site will likely have a role, the lengths of each segment and number of insertions/deletions are arbitrarily chosen (with cues from the textbook), and an animation to slide over the antibody when the B cell expresses it isn’t there. Nevertheless, this hopefully gets the point across.
