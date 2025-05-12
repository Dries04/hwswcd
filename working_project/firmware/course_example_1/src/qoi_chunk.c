#include "qoi_chunk.h"
#include "sensor.h"

unsigned int chunk_fetch(void) {
    unsigned int chunk_result;
    chunk_result = QOI_CHUNK_RESULT;
    //chunk_result_result = QOI_CHUNK_RESULT_RESULT;
    // SENSOR_CR |= SENSOR_CR_RE; 
    // SENSOR_CR &= ~SENSOR_CR_RE; 
    return chunk_result;
}
