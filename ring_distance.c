/* Author: Matjaž <dev@matjaz.it> matjaz.it
 *
 * This Source Code Form is subject to the terms of the BSD 3-Clause License.
 */

#include <stdio.h>   /* Allows usage of printf() */
#include <stdbool.h> /* Allows usage of booleans */
#include <stdlib.h>  /* Allows usage of abs() */

struct oriented_arc_struct {
    int lenght;
    bool clockwise;
};

typedef struct oriented_arc_struct oriented_arc;
int circumference = 12;
int start_point;
int end_point;
oriented_arc arc;
char hrule[50] = "\t+-------+-----+----------+------------------+\n";
char header[50] = "\t| Start | End | Distance |     Direction    |\n";
char ring[100] = "\
\t\t      12\n\
\t\t    11   1\n\
\t\t  10  \\    2\n\
\t\t 9     o---  3\n\
\t\t   8       4\n\
\t\t     7   5\n\
\t\t       6\n";

oriented_arc min_ring_distance(int circumference, int start_point, int end_point) {
    int distance_1 = end_point - start_point;
    oriented_arc arc_1 = {abs(distance_1), (distance_1 >= 0) ? true : false};
    oriented_arc arc_2 = {circumference - arc_1.lenght, !arc_1.clockwise};
    if (arc_1.lenght <= arc_2.lenght) {
        return arc_1;
    } else {
        return arc_2;
    }
}

int main() {
    printf("%s", ring);
    printf("%s", hrule);
    printf("%s", header);
    printf("%s", hrule);
    for (start_point = 1; start_point <= circumference; start_point++) {
        for (end_point = 1; end_point <= circumference; end_point++) {
            arc = min_ring_distance(circumference,
                    start_point, end_point);
            printf("\t|  %4i |%4i |     %4i | %s |\n",
                    start_point, end_point,
                    arc.lenght, arc.clockwise ? "    Clockwise   " : "Counterclockwise");
        }
        printf("%s", hrule);
    }
}
