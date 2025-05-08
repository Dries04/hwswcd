#ifndef QOI_CHUNK_H
#define QOI_CHUNK_H

#define QOI_CHUNK_BASEADDRESS        0x83000000

#define QOI_CHUNK_REG0_ADDRESS       (QOI_CHUNK_BASEADDRESS + 0*4)
#define QOI_CHUNK_REG1_ADDRESS       (QOI_CHUNK_BASEADDRESS + 1*4)
#define QOI_CHUNK_REG2_ADDRESS       (QOI_CHUNK_BASEADDRESS + 2*4)
#define QOI_CHUNK_REG3_ADDRESS       (QOI_CHUNK_BASEADDRESS + 3*4)

#define QOI_CHUNK_CR                 (*(volatile unsigned int *) QOI_CHUNK_REG0_ADDRESS)
#define QOI_CHUNK_RESULT               (*(volatile unsigned int *) QOI_CHUNK_REG1_ADDRESS)
#define QOI_CHUNK_SR                 (*(volatile unsigned int *) QOI_CHUNK_REG2_ADDRESS)
#define QOI_CHUNK_VAL                (*(volatile unsigned int *) QOI_CHUNK_REG3_ADDRESS)



#endif
