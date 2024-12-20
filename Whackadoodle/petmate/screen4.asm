

// PETSCII memory layout (example for a 40x25 screen)'
// byte  0         = border color'
// byte  1         = background color'
// bytes 2-1001    = screencodes'
// bytes 1002-2001 = color

was1:
.byte 0,0
.byte 32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32
.byte 160,160,160,160,160,160,160,242,160,240,221,240,160,238,240,238,238,240,160,238,242,201,213,160,213,201,242,201,242,160,213,201,160,160,160,160,160,160,160,160
.byte 160,160,160,160,160,160,160,221,221,221,235,243,213,243,221,160,235,254,213,243,200,200,213,201,202,203,200,200,221,160,235,203,160,160,160,160,160,160,160,160
.byte 160,160,160,160,160,160,160,237,241,253,253,237,202,253,237,253,253,237,202,253,241,203,202,203,160,203,241,203,237,195,202,195,160,22,50,160,160,160,160,160
.byte 160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160
.byte 160,160,160,160,160,160,160,160,160,160,236,126,98,98,98,124,251,160,160,160,160,160,236,126,98,98,98,124,251,160,160,160,160,160,160,160,160,160,160,160
.byte 160,160,160,160,160,160,160,160,160,236,108,160,160,160,160,160,123,251,160,160,160,236,108,160,160,160,160,160,123,251,160,160,160,160,160,160,160,160,160,160
.byte 160,160,160,160,160,160,160,160,160,126,160,255,160,160,160,160,160,124,160,160,160,126,160,255,160,160,160,160,160,124,160,160,160,160,160,160,160,160,160,160
.byte 160,160,160,160,160,160,160,160,160,225,160,160,160,160,160,160,160,97,160,160,160,225,160,160,160,160,160,160,160,97,160,160,160,160,160,160,160,160,160,160
.byte 160,160,160,160,160,160,160,160,160,225,160,160,160,160,160,160,160,97,160,160,160,225,160,160,160,160,160,160,160,97,160,160,160,160,160,160,160,160,160,160
.byte 160,160,160,160,160,160,160,160,160,123,160,160,160,160,160,160,160,108,160,160,160,123,160,160,160,160,160,160,160,108,160,160,160,160,160,160,160,160,160,160
.byte 160,160,160,160,160,160,160,160,160,252,124,160,160,160,160,160,126,254,160,160,160,252,124,160,160,160,160,160,126,254,160,160,160,160,160,160,160,160,160,160
.byte 160,160,160,160,160,160,160,160,160,160,252,123,226,226,226,108,254,160,160,160,160,160,252,123,226,226,226,108,254,160,160,160,160,160,160,160,160,160,160,160
.byte 160,160,160,160,236,126,98,98,98,124,251,160,160,160,160,160,236,126,98,98,98,124,251,160,160,160,160,160,236,126,98,98,98,124,251,160,160,160,160,160
.byte 160,160,160,236,108,160,160,160,160,160,123,251,160,160,160,236,108,160,160,160,160,160,123,251,160,160,160,236,108,160,160,160,160,160,123,251,160,160,160,160
.byte 160,160,160,126,160,255,160,160,160,160,160,124,160,160,160,126,160,255,160,160,160,160,160,124,160,160,160,126,160,255,160,160,160,160,160,124,160,160,160,160
.byte 160,160,160,225,160,160,160,160,160,160,160,97,160,160,160,225,160,160,160,160,160,160,160,97,160,160,160,225,160,160,160,160,160,160,160,97,160,160,160,160
.byte 160,160,160,225,160,133,129,147,153,161,160,97,160,160,160,225,160,142,143,146,141,129,140,97,160,160,160,225,160,160,136,129,146,132,160,97,160,160,160,160
.byte 160,160,160,123,160,160,160,160,160,160,160,108,160,160,160,123,160,160,160,160,160,160,160,108,160,160,160,123,160,160,160,160,160,160,160,108,160,160,160,160
.byte 160,160,160,252,124,160,160,160,160,160,126,254,160,160,160,252,124,160,160,160,160,160,126,254,160,160,160,252,124,160,160,160,160,160,126,254,160,160,160,160
.byte 160,160,160,160,252,123,226,226,226,108,254,160,160,160,160,160,252,123,226,226,226,108,254,160,160,160,160,160,252,123,226,226,226,108,254,160,160,160,160,160
.byte 160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160
.byte 160,160,160,160,160,160,160,160,160,178,176,178,180,160,153,143,149,148,149,130,133,174,131,143,141,175,131,137,148,153,152,133,142,160,160,160,160,160,160,160
.byte 160,160,160,160,160,160,134,129,137,146,135,146,143,149,142,132,160,148,149,142,133,160,130,153,160,147,129,149,140,160,131,146,143,147,147,160,160,160,160,160
.byte 32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32
.byte 0,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,0
.byte 10,2,6,6,6,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,6,6,6,10,2
.byte 2,6,6,6,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,6,6,6,10
.byte 10,6,6,6,6,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,6,6,6,6,2
.byte 2,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,10
.byte 10,6,6,6,6,6,6,6,6,6,6,6,5,5,5,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,2
.byte 2,6,6,6,6,6,6,6,6,6,5,5,5,5,5,5,5,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,10
.byte 10,6,6,6,6,6,6,6,6,6,5,1,5,5,5,5,5,6,6,6,6,6,6,1,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,2
.byte 2,6,6,6,6,6,6,6,6,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,10
.byte 10,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,4,4,4,6,6,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,2
.byte 2,4,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,4,4,4,4,4,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,10
.byte 10,4,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,4,4,4,4,4,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,2
.byte 2,4,4,4,4,4,4,4,4,4,4,4,5,5,5,4,4,4,4,4,4,4,4,4,6,6,6,4,4,4,4,4,4,4,4,4,4,4,4,10
.byte 10,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,7,7,7,2,2,2,2,2,2,2,2,2,1,1,1,2,2,2,2,2,2,2
.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,7,7,7,7,7,7,7,2,2,2,2,2,1,1,1,1,1,1,1,2,2,2,2,10
.byte 10,2,2,2,2,1,2,2,2,2,2,2,2,2,2,2,7,1,7,7,7,7,7,2,2,2,2,2,1,1,1,1,1,1,1,2,2,2,2,2
.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,7,7,7,7,7,7,7,7,7,2,2,2,1,1,1,1,1,1,1,1,1,2,2,2,10
.byte 10,2,2,2,2,2,2,2,2,2,2,2,2,2,2,7,7,7,7,7,7,7,7,7,2,2,2,1,1,1,1,1,1,1,1,1,2,2,2,2
.byte 2,8,8,8,2,2,2,2,2,2,2,8,8,8,8,8,7,7,7,7,7,7,7,8,8,8,8,8,1,1,1,1,1,1,1,8,8,8,8,10
.byte 10,8,8,8,2,2,2,2,2,2,2,8,8,8,8,8,7,7,7,7,7,7,7,8,8,8,8,8,1,1,1,1,1,1,1,8,8,8,8,2
.byte 2,8,8,8,8,8,2,2,2,8,8,8,8,8,8,8,8,8,7,7,7,8,8,8,8,8,8,8,8,8,1,1,1,8,8,8,8,8,8,10
.byte 10,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,2
.byte 2,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,10
.byte 10,2,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,10,2
.byte 0,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,0
instruct:
.byte 0,0
.byte 160,160,160,160,223,95,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160
.byte 100,111,121,98,248,247,160,151,136,129,131,139,129,132,143,143,132,140,133,160,160,160,160,160,105,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.byte 98,98,98,98,98,123,95,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,105,233,160,160,160,160,160,160,160,160,160,160,160,160,160,160,223
.byte 32,32,32,32,32,32,32,95,160,137,142,147,148,146,149,131,148,137,143,142,147,160,105,233,105,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.byte 32,32,32,32,32,32,32,32,95,160,160,160,160,160,160,160,160,160,160,160,160,105,233,105,105,105,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,98,98,98,98,105,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.byte 32,105,8,9,20,32,61,32,45,49,32,19,3,15,18,5,32,32,160,32,160,32,32,105,8,9,20,32,61,32,43,49,32,19,3,15,18,5,32,32
.byte 32,105,8,9,20,32,61,32,45,49,32,12,9,6,5,32,32,32,160,32,32,32,32,13,9,19,19,32,61,32,45,49,32,12,9,6,5,32,32,32
.byte 32,5,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,5,5,32,32,32,32
.byte 32,5,5,5,32,32,32,32,32,32,32,32,32,5,5,5,32,32,160,32,32,160,32,5,5,32,32,32,32,32,32,32,32,32,5,5,5,5,5,5
.byte 32,254,160,160,160,160,160,160,160,160,160,160,160,160,252,32,32,32,160,32,160,160,32,254,160,160,160,160,160,160,160,160,160,160,160,160,160,252,32,32
.byte 32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,252,32,32,160,32,32,32,32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,252,32
.byte 32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32,32,160,223,32,223,32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32
.byte 32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32,32,95,160,223,95,223,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32
.byte 32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32,32,32,95,105,233,105,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32
.byte 32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32,32,32,32,32,105,32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32
.byte 32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32,32,32,32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32
.byte 32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32,32,32,32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32
.byte 32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32,10,49,58,32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32
.byte 32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32,32,32,32,32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32
.byte 32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32,32,149,32,146,32,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,32
.byte 32,251,160,160,160,160,160,160,160,160,160,160,160,160,236,160,32,140,32,132,32,134,160,251,160,160,160,160,160,160,160,160,160,160,160,160,160,236,160,32
.byte 32,236,251,160,160,160,160,160,160,160,160,160,160,160,160,236,32,32,32,32,32,32,160,32,251,160,160,160,160,160,160,160,160,160,160,160,160,160,236,32
.byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.byte 32,5,14,19,21,18,5,32,8,15,14,11,8,5,3,11,2,21,20,20,15,14,19,32,15,18,32,10,15,25,19,20,9,3,11,32,9,14,32,49
.byte 6,6,6,6,6,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14
.byte 14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,13
.byte 11,11,11,11,11,11,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
.byte 14,5,5,5,5,5,5,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,11,11,2,2,2,2,2,2,2,2,14,14,14,14,14,14,14
.byte 14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,11,11,0,0,2,2,2,2,2,2,2,2,2,14,14,14,14,14
.byte 14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,11,11,11,11,11,14,14,14,14,14,2,2,2,2,2,2,2,14,14,14,14,14
.byte 14,0,5,5,5,14,1,14,12,1,14,4,4,4,4,4,14,14,12,11,0,14,14,0,5,5,5,14,1,14,12,1,14,4,4,4,4,4,14,14
.byte 14,0,5,5,5,14,1,14,12,1,14,13,13,13,13,13,14,14,15,11,11,14,2,2,2,2,2,2,1,2,12,1,14,13,13,13,13,14,14,14
.byte 14,0,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,15,11,11,14,14,14,2,2,2,2,2,2,2,2,2,2,0,0,14,14,14,14
.byte 14,0,0,0,14,14,14,14,14,14,14,14,14,0,0,0,14,14,15,11,11,0,14,0,0,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0
.byte 14,5,5,5,5,5,5,5,5,5,5,5,5,5,5,11,14,14,15,11,0,0,14,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,11,2
.byte 14,5,5,5,5,5,5,5,5,5,5,5,5,5,5,11,14,14,15,11,11,12,14,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,11,2
.byte 14,5,5,5,5,5,5,5,5,5,5,5,5,5,5,11,14,14,15,15,11,5,12,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,11,2
.byte 14,5,5,5,5,5,5,5,5,5,5,5,5,5,5,11,14,14,15,15,15,5,5,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,11,2
.byte 14,5,5,5,5,5,5,5,5,5,5,5,5,5,5,11,14,14,11,15,15,5,5,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,11,2
.byte 14,5,5,5,5,5,5,5,5,5,5,5,5,5,5,11,14,14,14,14,11,5,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,11,2
.byte 14,5,5,5,5,5,5,5,5,5,5,5,5,5,5,11,14,14,14,14,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,11,11
.byte 14,5,5,5,5,5,5,5,5,5,5,5,5,5,5,11,14,14,14,14,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,11,11
.byte 14,5,5,5,5,5,5,5,5,5,5,5,5,5,5,11,14,12,12,1,2,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,11,11
.byte 14,5,5,5,5,5,5,5,5,5,5,5,5,5,5,11,14,14,2,2,14,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,11,11
.byte 14,5,5,5,5,5,5,5,5,5,5,5,5,5,5,11,2,2,5,2,6,2,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,11,11
.byte 14,5,5,5,5,5,5,5,5,5,5,5,5,5,5,11,1,2,2,7,2,1,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,11,11
.byte 5,0,11,11,11,11,11,11,11,11,11,11,11,11,11,11,2,13,2,5,5,5,0,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
.byte 5,2,2,2,2,2,1,1,1,2,2,2,2,2,2,12,14,14,14,14,14,14,14,14,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
.byte 2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
play:
.byte 0,0
.byte 58,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,58
.byte 160,160,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160,160
.byte 160,32,32,12,9,6,5,58,32,32,32,32,32,32,32,32,32,32,32,32,32,32,19,3,15,18,5,58,32,32,32,32,32,32,32,67,67,32,32,160
.byte 160,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160
.byte 160,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160
.byte 160,32,32,32,32,32,32,32,32,32,32,32,32,98,98,98,32,32,32,32,32,32,32,32,32,98,98,98,32,32,32,32,32,32,32,32,32,32,32,160
.byte 160,32,32,32,32,32,32,32,32,32,32,108,160,160,160,160,160,123,32,32,32,32,32,108,160,160,160,160,160,123,32,32,32,32,32,32,32,32,32,160
.byte 160,32,32,32,32,32,32,32,32,32,32,160,255,160,160,160,160,160,32,32,32,32,32,160,255,160,160,160,160,160,32,32,32,32,32,32,32,32,32,160
.byte 160,32,32,32,32,32,32,32,32,32,225,160,160,160,160,160,160,160,97,32,32,32,225,160,160,160,160,160,160,160,97,32,32,32,32,32,32,32,32,160
.byte 160,32,32,32,32,32,32,32,32,32,225,160,160,160,160,160,160,160,97,32,32,32,225,160,160,160,160,160,160,160,97,32,32,32,32,32,32,32,32,160
.byte 160,32,32,32,32,32,32,32,32,32,32,160,160,160,160,160,160,160,32,32,32,32,32,160,160,160,160,160,160,160,32,32,32,32,32,32,32,32,32,160
.byte 160,32,32,32,32,32,32,32,32,32,32,124,160,160,160,160,160,126,32,32,32,32,32,124,160,160,160,160,160,126,32,32,32,32,32,32,32,32,32,160
.byte 160,32,32,32,32,32,32,32,32,32,32,32,32,226,226,226,32,32,32,32,32,32,32,32,32,226,226,226,32,32,32,32,32,32,32,32,32,32,32,160
.byte 160,32,32,32,32,32,32,98,98,98,32,32,32,32,32,32,32,32,32,98,98,98,32,32,32,32,32,32,32,32,32,98,98,98,32,32,32,32,32,160
.byte 160,32,32,32,32,108,160,160,160,160,160,123,32,32,32,32,32,108,160,160,160,160,160,123,32,32,32,32,32,108,160,160,160,160,160,123,32,32,32,160
.byte 160,32,32,32,32,160,255,160,160,160,160,160,32,32,32,32,32,160,255,160,160,160,160,160,32,32,32,32,32,160,255,160,160,160,160,160,32,32,32,160
.byte 160,32,32,32,225,160,160,160,160,160,160,160,97,32,32,32,225,160,160,160,160,160,160,160,97,32,32,32,225,160,160,160,160,160,160,160,97,32,32,160
.byte 160,32,32,32,225,160,160,160,160,160,160,160,97,32,32,32,225,160,160,160,160,160,160,160,97,32,32,32,225,160,160,160,160,160,160,160,97,32,32,160
.byte 160,32,32,32,32,160,160,160,160,160,160,160,32,32,32,32,32,160,160,160,160,160,160,160,32,32,32,32,32,160,160,160,160,160,160,160,32,32,32,160
.byte 160,32,32,32,32,124,160,160,160,160,160,126,32,32,32,32,32,124,160,160,160,160,160,126,32,32,32,32,32,124,160,160,160,160,160,126,32,32,32,160
.byte 160,32,32,32,32,32,32,226,226,226,32,32,32,32,32,32,32,32,32,226,226,226,32,32,32,32,32,32,32,32,32,226,226,226,32,32,32,32,32,160
.byte 160,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160
.byte 160,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160
.byte 160,160,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160,160
.byte 58,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,58
.byte 0,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,0
.byte 10,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,10,2
.byte 2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,7,7,7,7,7,7,2,0,0,1,1,10
.byte 10,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,5,5,5,5,5,5,5,1,5,5,5,5,5,5,5,1,1,1,1,1,1,2
.byte 2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,10
.byte 10,1,1,1,1,1,1,1,1,1,1,14,14,5,5,5,1,1,1,1,1,1,1,1,1,6,6,6,1,1,1,1,1,1,1,1,1,1,1,2
.byte 2,1,1,1,1,1,1,1,1,1,14,5,5,5,5,5,5,5,1,1,1,1,14,6,6,6,6,6,6,6,1,1,1,1,1,1,1,1,1,10
.byte 10,1,1,1,1,1,1,1,1,1,14,5,1,5,5,5,5,5,1,1,1,1,14,6,1,6,6,6,6,6,1,1,1,1,1,1,1,1,1,2
.byte 2,1,1,1,1,1,1,1,1,1,5,5,5,5,5,5,5,5,5,1,1,1,6,6,6,6,6,6,6,6,6,1,1,1,1,1,1,1,1,10
.byte 10,1,1,1,1,1,1,1,1,1,5,5,5,5,5,5,5,5,5,1,1,1,6,6,6,6,6,6,6,6,6,1,1,1,1,1,1,1,1,2
.byte 2,1,1,1,1,1,1,1,1,1,1,5,5,5,5,5,5,5,1,1,1,1,1,6,6,6,6,6,6,6,1,1,1,1,1,1,1,1,1,10
.byte 10,1,1,1,1,1,1,1,1,1,1,5,5,5,5,5,5,5,1,1,1,1,1,6,6,6,6,6,6,6,1,1,1,1,1,1,1,1,1,2
.byte 2,1,1,1,1,1,1,1,1,1,1,14,14,5,5,5,14,14,1,1,1,1,1,14,14,6,6,6,6,1,1,1,1,1,1,1,1,1,1,10
.byte 10,1,1,1,1,1,14,2,2,2,1,14,14,14,14,14,14,1,1,7,7,7,1,14,14,14,14,1,1,1,1,1,1,1,14,1,1,1,1,2
.byte 2,1,1,1,1,2,2,2,2,2,2,2,14,14,14,14,1,7,7,7,7,7,7,7,14,14,14,1,14,1,1,1,1,1,1,1,1,1,1,10
.byte 10,1,1,1,1,2,1,2,2,2,2,2,1,1,1,1,14,7,1,7,7,7,7,7,1,1,1,1,14,1,1,1,1,1,1,1,1,1,1,2
.byte 2,1,1,1,2,2,2,2,2,2,2,2,2,1,1,1,7,7,7,7,7,7,7,7,7,1,1,1,1,1,1,1,1,1,1,1,1,1,1,10
.byte 10,1,1,1,2,2,2,2,2,2,2,2,2,1,1,1,7,7,7,7,7,7,7,7,7,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2
.byte 2,1,1,1,2,2,2,2,2,2,2,2,1,1,1,1,14,7,7,7,7,7,7,7,1,1,1,1,14,1,1,1,1,1,1,1,1,1,1,10
.byte 10,1,1,1,1,2,2,2,2,2,2,2,1,1,1,1,1,7,7,7,7,7,7,7,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2
.byte 2,1,1,1,1,1,1,2,2,2,1,1,1,1,1,1,1,1,1,7,7,7,14,1,1,1,1,1,1,14,14,1,1,1,14,1,1,1,1,10
.byte 10,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2
.byte 2,1,1,1,1,1,1,1,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,10
.byte 10,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,10,2
.byte 0,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,10,2,0
scr_gameover:
.byte 0,0
.byte 32,32,32,32,32,32,32,32,32,32,160,160,160,160,160,160,160,160,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.byte 2,5,20,20,5,18,32,32,160,160,160,160,160,160,160,160,160,160,160,32,32,32,15,8,32,14,15,33,32,32,32,32,32,32,32,32,32,32,32,32
.byte 32,32,32,32,32,32,32,32,160,160,160,160,160,160,160,160,160,160,160,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,2,25,5,33,32,32
.byte 32,12,21,3,11,25,32,160,160,32,32,32,32,160,160,32,32,32,160,160,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.byte 32,32,32,32,32,32,32,160,160,32,32,32,32,160,160,32,32,32,160,160,32,32,32,32,6,9,14,1,12,12,25,32,32,32,32,32,32,32,32,32
.byte 14,5,24,20,32,32,32,160,160,160,160,160,160,160,160,160,160,160,160,160,32,32,32,32,32,19,3,15,18,5,33,32,32,32,32,32,32,32,32,32
.byte 32,32,32,32,32,32,32,32,160,160,160,160,160,160,32,160,160,160,160,160,32,32,32,32,32,32,32,32,32,32,32,32,32,32,4,5,1,4,33,32
.byte 32,3,25,3,12,5,33,32,32,160,160,160,160,160,160,160,160,160,32,32,32,254,160,160,160,160,160,160,160,160,160,160,252,32,32,32,32,32,32,32
.byte 32,32,32,32,32,32,32,32,32,32,160,160,32,160,32,160,32,160,32,32,32,160,236,32,32,32,32,32,32,32,32,251,160,32,32,32,32,32,32,254
.byte 32,32,32,32,32,32,32,32,32,32,32,32,160,32,160,160,160,32,32,32,32,160,32,32,32,32,32,32,32,32,32,32,160,32,32,32,32,32,254,160
.byte 32,32,32,32,32,32,32,32,32,32,160,160,32,32,32,32,32,160,32,32,32,160,252,32,32,32,32,32,32,32,32,254,160,32,32,32,32,254,160,160
.byte 32,32,32,32,32,32,32,32,32,32,32,32,160,160,160,160,160,32,32,32,32,251,160,160,160,160,160,160,160,160,160,160,236,32,32,32,254,160,160,160
.byte 254,32,32,254,160,160,160,236,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,254,160,160,87,160,160
.byte 160,32,32,160,236,32,32,32,254,160,252,32,254,32,32,32,252,32,254,160,236,32,32,32,32,32,32,32,32,160,160,160,160,160,160,160,160,160,87,160
.byte 160,225,225,160,32,98,98,225,160,32,160,225,160,160,254,160,160,225,160,98,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160,160,160
.byte 160,225,225,160,252,254,160,225,160,98,160,225,160,32,236,32,160,225,160,32,32,32,19,15,32,19,15,18,18,25,33,32,160,32,160,160,32,160,160,160
.byte 251,32,32,251,160,160,236,32,236,32,251,32,251,32,32,32,251,32,251,160,252,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160,160,160,160,32,160,160
.byte 254,32,254,32,254,32,254,32,32,32,254,160,252,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.byte 160,32,160,32,160,32,160,32,32,32,160,236,251,252,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160,160,160,160,32,32
.byte 160,225,160,225,160,225,160,225,225,225,160,32,32,160,32,252,32,252,32,254,160,236,32,254,98,226,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.byte 160,225,160,225,160,225,160,225,225,225,160,32,32,160,225,160,32,160,225,160,98,32,32,160,32,32,32,16,18,5,19,19,32,18,32,20,15,32,32,32
.byte 160,32,160,32,160,32,160,32,32,32,160,252,254,160,32,251,252,236,225,160,32,32,32,160,32,15,18,32,1,14,25,32,2,21,20,20,15,14,32,32
.byte 251,32,251,32,251,32,251,32,32,32,251,160,160,32,32,32,251,32,32,251,160,252,32,236,32,32,32,25,15,21,32,18,5,20,18,25,33,32,32,32
.byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.byte 14,14,14,14,14,14,14,14,11,11,11,11,12,12,15,12,15,15,14,15,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14
.byte 2,10,10,15,10,2,11,11,11,11,12,12,11,12,12,15,15,15,15,15,14,14,7,7,14,7,7,1,14,14,14,14,14,14,14,14,14,14,14,14
.byte 14,14,14,14,14,14,2,14,11,12,11,11,12,12,12,15,15,15,1,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,9,9,9,1,14,14
.byte 14,2,10,15,10,2,2,11,11,11,12,12,12,12,15,15,15,1,15,1,14,14,14,14,14,14,14,14,14,14,1,1,14,14,14,14,14,14,14,14
.byte 14,14,14,14,14,14,2,11,11,12,12,12,12,12,12,1,15,1,1,1,14,14,14,5,5,5,5,5,13,1,15,14,14,14,14,14,14,14,14,14
.byte 2,10,15,2,14,11,2,11,11,12,11,11,12,12,15,15,15,1,1,1,14,14,14,14,14,5,5,13,1,15,1,14,14,14,14,14,14,14,14,14
.byte 14,14,14,14,14,11,11,11,11,11,12,12,12,12,15,15,1,15,1,1,14,14,15,15,15,15,15,15,15,15,15,15,14,14,4,4,4,4,1,14
.byte 14,2,10,15,10,2,1,14,14,12,11,11,15,12,12,15,15,1,14,14,14,6,6,6,6,6,6,6,6,6,6,6,6,14,14,14,14,14,14,14
.byte 14,14,14,14,14,14,14,14,14,12,12,12,12,12,15,15,14,1,14,14,14,6,6,14,6,6,6,6,6,6,6,6,6,6,14,0,0,14,14,7
.byte 14,14,14,14,14,14,14,14,14,12,12,12,12,15,15,15,1,14,2,2,2,6,14,0,0,0,0,0,0,0,0,14,6,6,1,0,0,14,7,7
.byte 14,14,14,14,14,14,14,14,14,1,12,12,12,15,15,14,14,1,14,14,14,6,6,14,14,14,14,14,14,14,14,6,6,6,0,0,14,7,7,7
.byte 14,14,1,14,14,14,14,14,14,1,2,2,15,15,15,15,1,2,1,14,14,6,6,6,6,6,6,6,6,6,6,6,6,6,14,14,7,7,7,7
.byte 13,5,10,10,10,10,10,10,2,2,2,14,14,14,14,14,14,14,14,14,14,14,6,6,6,6,6,6,6,6,6,6,6,6,7,7,7,8,7,7
.byte 13,5,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,0,0,0,0,0,0,0,7,7,7,7,7,7,7,7,7,8,7
.byte 13,5,10,10,10,2,2,10,10,10,10,10,2,2,2,2,10,10,10,10,10,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,7,7
.byte 13,5,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,14,14,14,10,10,2,10,10,10,10,10,1,14,7,0,7,7,0,7,7,7
.byte 5,13,14,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 14,13,2,2,2,14,14,14,14,14,2,2,2,2,2,2,14,14,14,14,14,0,0,0,0,0,0,0,0,0,0,0,0,7,7,7,7,0,7,7
.byte 13,13,13,5,13,13,13,5,10,10,10,10,10,10,2,2,14,14,14,14,14,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 13,13,13,13,13,13,13,13,13,10,10,10,10,10,10,10,10,10,10,10,10,0,0,0,0,0,0,0,0,0,0,0,0,0,7,7,7,7,0,0
.byte 13,13,13,13,13,13,13,13,5,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,1,1,1,10,2,1,0,0,0,0,0,0,0,0
.byte 5,5,13,5,5,5,5,5,5,2,2,10,10,10,10,10,2,2,2,2,10,10,10,10,1,1,2,3,3,3,3,3,3,1,3,3,3,0,0,0
.byte 5,5,5,5,5,5,5,5,14,14,2,2,2,2,2,2,2,2,2,2,2,14,2,2,1,14,14,14,1,1,1,14,14,14,14,14,14,14,14,14
.byte 5,5,5,5,5,5,5,2,2,2,2,2,2,14,14,2,2,2,2,2,2,2,2,2,14,14,14,3,3,3,14,3,3,3,3,3,1,14,0,0
.byte 14,14,14,5,5,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,0,0,0
