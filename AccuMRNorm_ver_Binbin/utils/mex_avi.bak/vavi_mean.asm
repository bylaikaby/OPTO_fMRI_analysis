; Listing generated by Microsoft (R) Optimizing Compiler Version 12.00.9044.0 

	TITLE	vavi_mean.c
	.386P
include listing.inc
if @Version gt 510
.model FLAT
else
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT DWORD USE32 PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT DWORD USE32 PUBLIC 'BSS'
_BSS	ENDS
$$SYMBOLS	SEGMENT BYTE USE32 'DEBSYM'
$$SYMBOLS	ENDS
_TLS	SEGMENT DWORD USE32 PUBLIC 'TLS'
_TLS	ENDS
;	COMDAT ??_C@_0EL@CBBH@Usage?3?5?$FLimgmean?5imgstd?5width?5hei@
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT ??_C@_0DM@FEOM@Notes?3?5frames?$DO?$DN0?0?5length?$CIframes?$CJ@
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT ??_C@_0DC@BBNH@?5?5?5?5?5?3?5frame?5of?5?91?5is?5treated?5as@
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT ??_C@_0EP@HMIA@?5?5?5?5?5?3?5if?5?8frames?8?5is?5empty?0?5the@
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT ??_C@_0CO@IPJB@vavi_mean?3?5first?5arg?5must?5be?5fil@
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT ??_C@_0DL@DIKJ@vavi_mean?3?5not?5enough?5space?0?5fil@
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT ??_C@_02DILL@?$CFs?$AA@
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT ??_C@_0CB@HGLO@?6vavi_mean?3?5avifile?$DN?$CFs?0frame?$DN?$CFd?6@
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT ??_C@_0BN@BKLJ@vavi_mean?3?5OpenAVI?$CI?$CJ?5failed?4?$AA@
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT ??_C@_0EJ@FLLM@?6vavi_mean?3?5empty?5?8frames?8?5detec@
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT ??_C@_0EA@NMIL@?6vavi_mean?3?5num?4frames?$FL?$CFd?$FN?5shoul@
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT ??_C@_0CC@BIFP@vavi_mean?3?5GrabAVIFrame?$CI?$CJ?5failed@
_DATA	SEGMENT DWORD USE32 PUBLIC 'DATA'
_DATA	ENDS
;	COMDAT _addRaw2Image
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT _addRaw2ImageAsm
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT _procRaw2Image
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT _procRaw2ImageAsm
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT _alignImage4Matlab
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT _mexFunction
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
;	COMDAT _DllMain@12
_TEXT	SEGMENT PARA USE32 PUBLIC 'CODE'
_TEXT	ENDS
FLAT	GROUP _DATA, CONST, _BSS
	ASSUME	CS: FLAT, DS: FLAT, SS: FLAT
endif

INCLUDELIB MSVCRT
INCLUDELIB OLDNAMES

PUBLIC	_addRaw2Image
; Function compile flags: /Ogt
; File vavi_mean.c
;	COMDAT _addRaw2Image
_TEXT	SEGMENT
_buf$ = 8
_raw$ = 12
_npts$ = 16
_addRaw2Image PROC NEAR					; COMDAT

; 67   : {

	push	ebp
	mov	ebp, esp
	push	edi

; 68   :   int i, j;
; 69   : #if 1
; 70   :   unsigned long tmpv[4];
; 71   :   for (i = 0; i < npts; i+=4) {

	mov	edi, DWORD PTR _npts$[ebp]
	test	edi, edi
	jle	SHORT $L53012
	mov	edx, DWORD PTR _raw$[ebp]
	mov	eax, DWORD PTR _buf$[ebp]
	push	ebx
	push	esi
	or	esi, -1
	add	eax, 8
	lea	ecx, DWORD PTR [edx+1]
	sub	esi, edx
$L53010:

; 72   :     buf[i]   = buf[i]   + raw[i];

	mov	ebx, DWORD PTR [eax-8]
	xor	edx, edx
	mov	dl, BYTE PTR [ecx-1]
	add	ecx, 4
	add	ebx, edx

; 73   :     buf[i+1] = buf[i+1] + raw[i+1];

	xor	edx, edx
	mov	DWORD PTR [eax-8], ebx
	mov	dl, BYTE PTR [ecx-4]
	mov	ebx, DWORD PTR [eax-4]
	add	eax, 16					; 00000010H
	add	ebx, edx

; 74   :     buf[i+2] = buf[i+2] + raw[i+2];

	xor	edx, edx
	mov	DWORD PTR [eax-20], ebx
	mov	dl, BYTE PTR [ecx-3]
	mov	ebx, DWORD PTR [eax-16]
	add	ebx, edx

; 75   :     buf[i+3] = buf[i+3] + raw[i+3];

	xor	edx, edx
	mov	DWORD PTR [eax-16], ebx
	mov	dl, BYTE PTR [ecx-2]
	mov	ebx, DWORD PTR [eax-12]
	add	ebx, edx
	lea	edx, DWORD PTR [esi+ecx]
	mov	DWORD PTR [eax-12], ebx
	cmp	edx, edi
	jl	SHORT $L53010
	pop	esi
	pop	ebx
$L53012:
	pop	edi

; 76   :   }
; 77   : #else
; 78   :   for (i = 0; i < npts; i+=4) {
; 79   :     tmpv[0] = raw[i];
; 80   :     tmpv[1] = raw[i+1];
; 81   :     tmpv[2] = raw[i+2];
; 82   :     tmpv[3] = raw[i+3];
; 83   :     buf[i]   = buf[i]   + tmpv[0];
; 84   :     buf[i+1] = buf[i+1] + tmpv[1];
; 85   :     buf[i+2] = buf[i+2] + tmpv[2];
; 86   :     buf[i+3] = buf[i+3] + tmpv[3];
; 87   :     //buf[j]   = buf[j]   + tmpv[0]*tmpv[0];
; 88   :     //buf[j+1] = buf[j+1] + tmpv[1]*tmpv[1];
; 89   :     //buf[j+2] = buf[j+2] + tmpv[2]*tmpv[2];
; 90   :     //buf[j+3] = buf[j+3] + tmpv[3]*tmpv[3];
; 91   :   }
; 92   : 
; 93   :   unsigned long *lraw, tmpv;
; 94   :   lraw = raw;
; 95   :   for (j = 0; j < npts*2; j+=8) {
; 96   :     tmpv = lraw[j/2];
; 97   :     buf[j]   = buf[j]   + tmpv & 0xff;
; 98   :     buf[j+2] = buf[j+2] + (tmpv >>  8) & 0xff;
; 99   :     buf[j+4] = buf[j+4] + (tmpv >> 16) & 0xff;
; 100  :     buf[j+6] = buf[j+6] + (tmpv >> 24) & 0xff;
; 101  :   }
; 102  : #endif
; 103  :   return;
; 104  : }

	pop	ebp
	ret	0
_addRaw2Image ENDP
_TEXT	ENDS
PUBLIC	_addRaw2ImageAsm
; Function compile flags: /Ogt
;	COMDAT _addRaw2ImageAsm
_TEXT	SEGMENT
_buf$ = 8
_raw$ = 12
_npts$ = 16
_addRaw2ImageAsm PROC NEAR				; COMDAT

; 107  : {

	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	push	edi

; 110  :     //prefetcht0 raw;
; 111  :     //prefetcht0 buf;
; 112  :     mov ecx, npts;  // u

	mov	ecx, DWORD PTR _npts$[ebp]

; 113  :     mov esi, raw;   // v

	mov	esi, DWORD PTR _raw$[ebp]

; 114  :     shr ecx, 1;     // u: divide by 2

	shr	ecx, 1

; 115  :     //xor eax, eax;
; 116  :     mov edi, buf;   // v

	mov	edi, DWORD PTR _buf$[ebp]
$label$53020:

; 117  :   label:
; 118  :     xor eax, eax;

	xor	eax, eax

; 119  :     xor ebx, ebx;

	xor	ebx, ebx

; 120  :     mov al, [esi+0];

	mov	al, BYTE PTR [esi]

; 121  :     mov bl, [esi+1];

	mov	bl, BYTE PTR [esi+1]

; 122  : 
; 123  :     add [edi+0], eax;

	add	DWORD PTR [edi], eax

; 124  :     add [edi+4], ebx;

	add	DWORD PTR [edi+4], ebx

; 125  : 
; 126  :     //prefetcht0 [esi+2];
; 127  :     //prefetcht0 [edi+8];
; 128  :     add esi, 2;

	add	esi, 2

; 129  :     add edi, 8;

	add	edi, 8

; 130  : 
; 131  :     dec ecx;

	dec	ecx

; 132  :     jnz label;

	jne	SHORT $label$53020

; 108  : #if 1
; 109  :   __asm {

	pop	edi
	pop	esi
	pop	ebx

; 133  : 
; 134  :   }
; 135  : #else
; 136  :     //prefetcht0 raw;
; 137  :     //prefetcht0 buf;
; 138  :     mov ecx, npts;  // u
; 139  :     mov esi, raw;   // v
; 140  :     shr ecx, 1;     // u: divide by 2
; 141  :     mov edi, buf;   // v
; 142  :     xor eax, eax;
; 143  :     xor ebx, ebx;
; 144  :   label:
; 145  :     mov al, [esi+0];
; 146  :     mov bl, [esi+1];
; 147  : 
; 148  :     add [edi+0], eax;
; 149  :     add [edi+4], ebx;
; 150  : 
; 151  :     //prefetcht0 [esi+2];
; 152  :     //prefetcht0 [edi+8];
; 153  :     xor eax, eax;
; 154  :     xor ebx, ebx;
; 155  :     add esi, 2;
; 156  :     add edi, 8;
; 157  : 
; 158  :     dec ecx;
; 159  :     jnz label;
; 160  : 
; 161  : 
; 162  :   unsigned long tmpv[2];
; 163  :   __asm {
; 164  :     //prefetcht0 raw;
; 165  :     //prefetcht0 buf;
; 166  :     xor eax, eax;
; 167  :     lea edx, [tmpv];
; 168  :     mov ecx, npts;  // u
; 169  :     mov esi, raw;   // v
; 170  :     shr ecx, 1;     // u: divide by 2
; 171  :     mov edi, buf;   // v
; 172  :   label:
; 173  :     //prefetcht0 [edi]
; 174  :     xor eax, eax;
; 175  :     xor ebx, ebx;
; 176  :     mov al, [esi+0];
; 177  :     mov bl, [esi+1];
; 178  : 
; 179  :     mov [edx+0], eax;
; 180  :     mov [edx+4], ebx;
; 181  : 
; 182  :     movq mm1, [edx+0];
; 183  :     movq mm0, [edi+0];
; 184  :  
; 185  :     paddd mm0, mm1;
; 186  :     movq [edi+0], mm0;
; 187  : 
; 188  :     //prefetcht0 [esi+4]
; 189  :     add esi, 2;
; 190  :     add edi, 8;
; 191  : 
; 192  :     //lea esi, [esi+2];
; 193  :     //lea edi, [edi+16];
; 194  : 
; 195  :     dec ecx;
; 196  :     jnz label;
; 197  : 
; 198  :     emms;
; 199  :   }
; 200  : #endif
; 201  : 
; 202  :   return;
; 203  : }

	pop	ebp
	ret	0
_addRaw2ImageAsm ENDP
_TEXT	ENDS
PUBLIC	_procRaw2Image
; Function compile flags: /Ogt
;	COMDAT _procRaw2Image
_TEXT	SEGMENT
_buf$ = 8
_raw$ = 12
_npts$ = 16
_tmpv$ = -36
_procRaw2Image PROC NEAR				; COMDAT

; 206  : {

	push	ebp
	mov	ebp, esp
	sub	esp, 36					; 00000024H
	push	edi

; 207  : #if 0
; 208  :   int i;
; 209  :   unsigned long tmpv;
; 210  :   for (i = 0; i < npts; i++) {
; 211  :     tmpv = raw[i];
; 212  :     buf[i] = buf[i] + tmpv;
; 213  :     buf[i+npts] = buf[i+npts] + tmpv*tmpv;
; 214  :   }
; 215  : #else
; 216  :   int i, j;
; 217  :   unsigned long tmpv[8];
; 218  :   for (i = 0, j = npts; i < npts; i+=4, j+=4) {

	mov	edi, DWORD PTR _npts$[ebp]
	test	edi, edi
	jle	$L53033
	mov	ecx, DWORD PTR _buf$[ebp]
	mov	edx, DWORD PTR _raw$[ebp]
	push	ebx
	push	esi
	lea	eax, DWORD PTR [ecx+8]
	lea	esi, DWORD PTR [edx+1]
	lea	ecx, DWORD PTR [ecx+edi*4+8]
	mov	edi, edx
	mov	ebx, edx
	sub	edx, esi
	add	edx, 3
	sub	ebx, esi
	mov	DWORD PTR -4+[ebp], edx
	mov	edx, DWORD PTR _npts$[ebp]
	sub	edi, esi
	add	ebx, 2
	dec	edx
	mov	DWORD PTR 12+[ebp], edi
	shr	edx, 2
	inc	edx
	mov	DWORD PTR 8+[ebp], ebx
	mov	DWORD PTR 16+[ebp], edx
	jmp	SHORT $L53031
$L53239:
	mov	edi, DWORD PTR 12+[ebp]
$L53031:

; 219  :     tmpv[0] = raw[i];

	xor	edx, edx

; 220  :     tmpv[1] = raw[i+1];
; 221  :     tmpv[2] = raw[i+2];

	mov	ebx, DWORD PTR 8+[ebp]
	mov	dl, BYTE PTR [edi+esi]
	add	esi, 4
	mov	edi, edx
	xor	edx, edx
	mov	dl, BYTE PTR [esi-4]
	add	eax, 16					; 00000010H
	mov	DWORD PTR _tmpv$[ebp+4], edx
	xor	edx, edx
	mov	dl, BYTE PTR [ebx+esi-4]

; 222  :     tmpv[3] = raw[i+3];

	mov	ebx, DWORD PTR -4+[ebp]
	mov	DWORD PTR _tmpv$[ebp+8], edx
	xor	edx, edx
	mov	dl, BYTE PTR [ebx+esi-4]

; 223  :     //tmpv[4] = raw[i+4];
; 224  :     //tmpv[5] = raw[i+5];
; 225  :     //tmpv[6] = raw[i+6];
; 226  :     //tmpv[7] = raw[i+7];
; 227  :     buf[i]   = buf[i]   + tmpv[0];

	mov	ebx, DWORD PTR [eax-24]
	add	ebx, edi
	add	ecx, 16					; 00000010H
	mov	DWORD PTR [eax-24], ebx

; 228  :     buf[i+1] = buf[i+1] + tmpv[1];

	mov	ebx, DWORD PTR _tmpv$[ebp+4]
	add	DWORD PTR [eax-20], ebx

; 229  :     buf[i+2] = buf[i+2] + tmpv[2];

	mov	ebx, DWORD PTR _tmpv$[ebp+8]
	add	DWORD PTR [eax-16], ebx

; 230  :     buf[i+3] = buf[i+3] + tmpv[3];

	mov	ebx, DWORD PTR [eax-12]
	add	ebx, edx
	mov	DWORD PTR [eax-12], ebx

; 231  :     buf[j]   = buf[j]   + tmpv[0]*tmpv[0];

	mov	ebx, edi
	imul	ebx, edi
	mov	edi, DWORD PTR [ecx-24]
	add	edi, ebx
	mov	DWORD PTR [ecx-24], edi

; 232  :     buf[j+1] = buf[j+1] + tmpv[1]*tmpv[1];

	mov	edi, DWORD PTR _tmpv$[ebp+4]
	mov	ebx, edi
	imul	ebx, edi
	mov	edi, DWORD PTR [ecx-20]
	add	edi, ebx
	mov	DWORD PTR [ecx-20], edi

; 233  :     buf[j+2] = buf[j+2] + tmpv[2]*tmpv[2];

	mov	edi, DWORD PTR _tmpv$[ebp+8]
	mov	ebx, edi
	imul	ebx, edi
	mov	edi, DWORD PTR [ecx-16]
	add	edi, ebx

; 234  :     buf[j+3] = buf[j+3] + tmpv[3]*tmpv[3];

	mov	ebx, DWORD PTR [ecx-12]
	mov	DWORD PTR [ecx-16], edi
	mov	edi, edx
	imul	edi, edx
	mov	edx, DWORD PTR 16+[ebp]
	add	ebx, edi
	mov	DWORD PTR [ecx-12], ebx
	dec	edx
	mov	DWORD PTR 16+[ebp], edx
	jne	$L53239
	pop	esi
	pop	ebx
$L53033:
	pop	edi

; 235  :     // force to prefetch
; 236  :     //tmpv[0] = raw[i+4];
; 237  :   }
; 238  : #endif
; 239  :   return;
; 240  : }

	mov	esp, ebp
	pop	ebp
	ret	0
_procRaw2Image ENDP
_TEXT	ENDS
PUBLIC	_procRaw2ImageAsm
; Function compile flags: /Ogt
;	COMDAT _procRaw2ImageAsm
_TEXT	SEGMENT
_buf$ = 8
_raw$ = 12
_npts$ = 16
_procRaw2ImageAsm PROC NEAR				; COMDAT

; 243  : {

	push	ebp
	mov	ebp, esp
	push	esi
	push	edi

; 246  :     mov esi, raw;

	mov	esi, DWORD PTR _raw$[ebp]

; 247  :     mov edi, buf;

	mov	edi, DWORD PTR _buf$[ebp]

; 248  :     mov ecx, npts;

	mov	ecx, DWORD PTR _npts$[ebp]

; 249  :     shr ecx, 2;   // divide by 4

	shr	ecx, 2

; 250  :     
; 251  :     mov eax, 0;

	mov	eax, 0
$label$53042:

; 252  :   label:
; 253  :     prefetcht0 [edi];

	prefetcht0 BYTE PTR [edi]

; 254  :     movd mm0, [esi];

	movd	mm0, DWORD PTR [esi]

; 255  :     movd mm1, eax;

	movd	mm1, eax

; 256  :     punpcklbw mm0, mm1;

	punpcklbw mm0, mm1

; 257  :     //movq mm1, mm0;
; 258  :     movq mm3, [edi];

	movq	mm3, MMWORD PTR [edi]

; 259  :     //movq mm4, [edi+4]
; 260  :     
; 261  :     paddd mm3, mm0;

	paddd	mm3, mm0

; 262  :     //pmuludq mm1,mm0;
; 263  :     //paddd mm4, mm1;
; 264  :     prefetcht0 [esi+4];

	prefetcht0 BYTE PTR [esi+4]

; 265  :     movntq [edi], mm3;       // movntq is faster than movq

	movntq	MMWORD PTR [edi], mm3

; 266  :     //movntq [edi+4],mm4;
; 267  :     //movq [edi], mm2
; 268  : 
; 269  :     //add esi, 4;
; 270  :     //add edi, 32;
; 271  :     lea esi, [esi+4];

	lea	esi, DWORD PTR [esi+4]

; 272  :     lea edi, [edi+32];

	lea	edi, DWORD PTR [edi+32]

; 273  : 
; 274  :     dec ecx;

	dec	ecx

; 275  :     jnz label;

	jne	SHORT $label$53042

; 276  : 
; 277  :     emms;

	emms

; 244  : #if 1
; 245  :   __asm {

	pop	edi
	pop	esi

; 278  :   }
; 279  : #else
; 280  :   int i, j;
; 281  :   unsigned long tmpv;
; 282  :   for (i = 0, j = 0; i < npts; i++, j+=2) {
; 283  :     tmpv = raw[i];
; 284  :     buf[j]   = buf[j]   + tmpv;
; 285  :   }
; 286  : #endif
; 287  :   return;
; 288  : }

	pop	ebp
	ret	0
_procRaw2ImageAsm ENDP
_TEXT	ENDS
PUBLIC	_alignImage4Matlab
EXTRN	__fltused:NEAR
; Function compile flags: /Ogt
;	COMDAT _alignImage4Matlab
_TEXT	SEGMENT
_mimg$ = 8
_iimg$ = 12
_width$ = 16
_height$ = 20
_j$ = -16
_alignImage4Matlab PROC NEAR				; COMDAT

; 292  : {

	push	ebp
	mov	ebp, esp
	sub	esp, 16					; 00000010H

; 293  :   int i, j, w, h, wh, wh2;
; 294  :   wh = height*width;

	mov	eax, DWORD PTR _height$[ebp]
	push	ebx
	mov	ebx, DWORD PTR _width$[ebp]
	push	edi
	mov	ecx, ebx

; 295  :   wh2 = 2*wh;
; 296  :   j = 0;

	xor	edi, edi
	imul	ecx, eax

; 297  :   for (h = height-1; h >= 0; h--) {

	dec	eax
	test	eax, eax
	jl	$L53060
	mov	edx, DWORD PTR _mimg$[ebp]
	push	esi
	lea	esi, DWORD PTR [edx+eax*8]
	mov	DWORD PTR 16+[ebp], esi
	lea	esi, DWORD PTR [eax+ecx]
	lea	ecx, DWORD PTR [eax+ecx*2]
	inc	eax
	lea	esi, DWORD PTR [edx+esi*8]
	mov	DWORD PTR -12+[ebp], eax
	mov	DWORD PTR 8+[ebp], esi
	lea	esi, DWORD PTR [edx+ecx*8]
	mov	DWORD PTR -8+[ebp], esi
	mov	eax, 8
$L53058:

; 298  :     i = h;
; 299  :     for (w = 0; w < width; w++) {

	test	ebx, ebx
	jle	SHORT $L53059
	mov	edx, DWORD PTR _iimg$[ebp]
	mov	ecx, DWORD PTR 16+[ebp]
	mov	DWORD PTR -4+[ebp], ebx
	lea	eax, DWORD PTR [edx+edi*8+16]
	mov	edx, DWORD PTR 8+[ebp]
	add	edi, ebx
	lea	edi, DWORD PTR [edi+ebx*2]
	mov	DWORD PTR _j$[ebp], edi
$L53061:

; 300  :       mimg[i]     = iimg[j];

	mov	edi, DWORD PTR [eax-16]

; 301  :       mimg[i+wh]  = iimg[j+1];
; 302  :       mimg[i+wh2] = iimg[j+2];
; 303  :       j += 3;

	add	eax, 24					; 00000018H
	mov	DWORD PTR [ecx], edi
	mov	edi, DWORD PTR [eax-36]
	mov	DWORD PTR [ecx+4], edi
	mov	edi, DWORD PTR [eax-32]
	mov	DWORD PTR [edx], edi
	mov	edi, DWORD PTR [eax-28]
	mov	DWORD PTR [edx+4], edi
	mov	edi, DWORD PTR [eax-24]
	mov	DWORD PTR [esi], edi
	mov	edi, DWORD PTR [eax-20]
	mov	DWORD PTR [esi+4], edi

; 304  :       i += height;

	mov	edi, DWORD PTR _height$[ebp]
	shl	edi, 3
	add	ecx, edi
	add	edx, edi
	add	esi, edi
	mov	edi, DWORD PTR -4+[ebp]
	dec	edi
	mov	DWORD PTR -4+[ebp], edi
	jne	SHORT $L53061
	mov	edi, DWORD PTR _j$[ebp]
	mov	eax, 8
$L53059:
	mov	edx, DWORD PTR 16+[ebp]
	mov	esi, DWORD PTR -8+[ebp]
	mov	ecx, DWORD PTR -12+[ebp]
	sub	edx, eax
	mov	DWORD PTR 16+[ebp], edx
	mov	edx, DWORD PTR 8+[ebp]
	sub	esi, eax
	sub	edx, eax
	dec	ecx
	mov	DWORD PTR -8+[ebp], esi
	mov	DWORD PTR 8+[ebp], edx
	mov	DWORD PTR -12+[ebp], ecx
	jne	SHORT $L53058
	pop	esi
$L53060:
	pop	edi
	pop	ebx

; 305  :     }
; 306  :   }
; 307  :   return;
; 308  : }

	mov	esp, ebp
	pop	ebp
	ret	0
_alignImage4Matlab ENDP
_TEXT	ENDS
PUBLIC	??_C@_0EL@CBBH@Usage?3?5?$FLimgmean?5imgstd?5width?5hei@ ; `string'
PUBLIC	??_C@_0DM@FEOM@Notes?3?5frames?$DO?$DN0?0?5length?$CIframes?$CJ@ ; `string'
PUBLIC	??_C@_0DC@BBNH@?5?5?5?5?5?3?5frame?5of?5?91?5is?5treated?5as@ ; `string'
PUBLIC	??_C@_0EP@HMIA@?5?5?5?5?5?3?5if?5?8frames?8?5is?5empty?0?5the@ ; `string'
PUBLIC	??_C@_0CO@IPJB@vavi_mean?3?5first?5arg?5must?5be?5fil@ ; `string'
PUBLIC	??_C@_0DL@DIKJ@vavi_mean?3?5not?5enough?5space?0?5fil@ ; `string'
PUBLIC	??_C@_02DILL@?$CFs?$AA@				; `string'
PUBLIC	??_C@_0CB@HGLO@?6vavi_mean?3?5avifile?$DN?$CFs?0frame?$DN?$CFd?6@ ; `string'
PUBLIC	??_C@_0BN@BKLJ@vavi_mean?3?5OpenAVI?$CI?$CJ?5failed?4?$AA@ ; `string'
PUBLIC	??_C@_0EJ@FLLM@?6vavi_mean?3?5empty?5?8frames?8?5detec@ ; `string'
PUBLIC	??_C@_0EA@NMIL@?6vavi_mean?3?5num?4frames?$FL?$CFd?$FN?5shoul@ ; `string'
PUBLIC	??_C@_0CC@BIFP@vavi_mean?3?5GrabAVIFrame?$CI?$CJ?5failed@ ; `string'
PUBLIC	_mexFunction
PUBLIC	__real@0000000000000000
PUBLIC	__real@3fe0000000000000
PUBLIC	__real@3f70101010101010
PUBLIC	__real@3ff0000000000000
PUBLIC	__real@40efc02000000000
EXTRN	_OpenAVI:NEAR
EXTRN	_GrabAVIFrame:NEAR
EXTRN	_mxCreateNumericArray:NEAR
EXTRN	_mxCreateDoubleMatrix:NEAR
EXTRN	_CloseAVI:NEAR
EXTRN	__imp__sprintf:NEAR
EXTRN	_mxGetString:NEAR
EXTRN	_mexErrMsgTxt:NEAR
EXTRN	_mexWarnMsgTxt:NEAR
EXTRN	_mexPrintf:NEAR
EXTRN	__imp__calloc:NEAR
EXTRN	__imp__free:NEAR
EXTRN	__ftol:NEAR
EXTRN	_mxCalloc:NEAR
EXTRN	_mxIsChar:NEAR
EXTRN	_mxGetPr:NEAR
EXTRN	_mxGetM:NEAR
EXTRN	_mxGetN:NEAR
;	COMDAT ??_C@_0EL@CBBH@Usage?3?5?$FLimgmean?5imgstd?5width?5hei@
_DATA	SEGMENT
??_C@_0EL@CBBH@Usage?3?5?$FLimgmean?5imgstd?5width?5hei@ DB 'Usage: [imgm'
	DB	'ean imgstd width heigth nframes] = vavi_mean(filename,frames)'
	DB	0aH, 00H					; `string'
_DATA	ENDS
;	COMDAT ??_C@_0DM@FEOM@Notes?3?5frames?$DO?$DN0?0?5length?$CIframes?$CJ@
_DATA	SEGMENT
??_C@_0DM@FEOM@Notes?3?5frames?$DO?$DN0?0?5length?$CIframes?$CJ@ DB 'Note'
	DB	's: frames>=0, length(frames)<66051.  ver.0.91 Sep-2003', 0aH, 00H ; `string'
_DATA	ENDS
;	COMDAT ??_C@_0DC@BBNH@?5?5?5?5?5?3?5frame?5of?5?91?5is?5treated?5as@
_DATA	SEGMENT
??_C@_0DC@BBNH@?5?5?5?5?5?3?5frame?5of?5?91?5is?5treated?5as@ DB '     : '
	DB	'frame of -1 is treated as a blank(black).', 0aH, 00H ; `string'
_DATA	ENDS
;	COMDAT ??_C@_0EP@HMIA@?5?5?5?5?5?3?5if?5?8frames?8?5is?5empty?0?5the@
_DATA	SEGMENT
??_C@_0EP@HMIA@?5?5?5?5?5?3?5if?5?8frames?8?5is?5empty?0?5the@ DB '     :'
	DB	' if ''frames'' is empty, then compute across all frames in th'
	DB	'e moviefile.', 0aH, 00H			; `string'
_DATA	ENDS
;	COMDAT ??_C@_0CO@IPJB@vavi_mean?3?5first?5arg?5must?5be?5fil@
_DATA	SEGMENT
??_C@_0CO@IPJB@vavi_mean?3?5first?5arg?5must?5be?5fil@ DB 'vavi_mean: fir'
	DB	'st arg must be filename string.', 00H	; `string'
_DATA	ENDS
;	COMDAT ??_C@_0DL@DIKJ@vavi_mean?3?5not?5enough?5space?0?5fil@
_DATA	SEGMENT
??_C@_0DL@DIKJ@vavi_mean?3?5not?5enough?5space?0?5fil@ DB 'vavi_mean: not'
	DB	' enough space, filename string is truncated.', 00H ; `string'
_DATA	ENDS
;	COMDAT ??_C@_02DILL@?$CFs?$AA@
_DATA	SEGMENT
??_C@_02DILL@?$CFs?$AA@ DB '%s', 00H			; `string'
_DATA	ENDS
;	COMDAT ??_C@_0CB@HGLO@?6vavi_mean?3?5avifile?$DN?$CFs?0frame?$DN?$CFd?6@
_DATA	SEGMENT
??_C@_0CB@HGLO@?6vavi_mean?3?5avifile?$DN?$CFs?0frame?$DN?$CFd?6@ DB 0aH, 'v'
	DB	'avi_mean: avifile=%s,frame=%d', 0aH, 00H	; `string'
_DATA	ENDS
;	COMDAT ??_C@_0BN@BKLJ@vavi_mean?3?5OpenAVI?$CI?$CJ?5failed?4?$AA@
_DATA	SEGMENT
??_C@_0BN@BKLJ@vavi_mean?3?5OpenAVI?$CI?$CJ?5failed?4?$AA@ DB 'vavi_mean:'
	DB	' OpenAVI() failed.', 00H			; `string'
_DATA	ENDS
;	COMDAT ??_C@_0EJ@FLLM@?6vavi_mean?3?5empty?5?8frames?8?5detec@
_DATA	SEGMENT
??_C@_0EJ@FLLM@?6vavi_mean?3?5empty?5?8frames?8?5detec@ DB 0aH, 'vavi_mea'
	DB	'n: empty ''frames'' detected, now compute across all frames ['
	DB	'%d].', 00H					; `string'
_DATA	ENDS
;	COMDAT __real@0000000000000000
CONST	SEGMENT
__real@0000000000000000 DQ 00000000000000000r	; 0
CONST	ENDS
;	COMDAT __real@3fe0000000000000
CONST	SEGMENT
__real@3fe0000000000000 DQ 03fe0000000000000r	; 0.5
CONST	ENDS
;	COMDAT ??_C@_0EA@NMIL@?6vavi_mean?3?5num?4frames?$FL?$CFd?$FN?5shoul@
_DATA	SEGMENT
??_C@_0EA@NMIL@?6vavi_mean?3?5num?4frames?$FL?$CFd?$FN?5shoul@ DB 0aH, 'v'
	DB	'avi_mean: num.frames[%d] should be < 66051 to avoid overflow.'
	DB	00H						; `string'
_DATA	ENDS
;	COMDAT ??_C@_0CC@BIFP@vavi_mean?3?5GrabAVIFrame?$CI?$CJ?5failed@
_DATA	SEGMENT
??_C@_0CC@BIFP@vavi_mean?3?5GrabAVIFrame?$CI?$CJ?5failed@ DB 'vavi_mean: '
	DB	'GrabAVIFrame() failed.', 00H		; `string'
_DATA	ENDS
;	COMDAT __real@3f70101010101010
CONST	SEGMENT
__real@3f70101010101010 DQ 03f70101010101010r	; 0.00392157
CONST	ENDS
;	COMDAT __real@3ff0000000000000
CONST	SEGMENT
__real@3ff0000000000000 DQ 03ff0000000000000r	; 1
CONST	ENDS
;	COMDAT __real@40efc02000000000
CONST	SEGMENT
__real@40efc02000000000 DQ 040efc02000000000r	; 65025
; Function compile flags: /Ogt
CONST	ENDS
;	COMDAT _mexFunction
_TEXT	SEGMENT
_nlhs$ = 8
_plhs$ = 12
_nrhs$ = 16
_prhs$ = 20
_iframes$ = 20
_imgbuff$ = -16
_imgstd$ = -12
_j$ = -4
_k$ = -20
_nframes$ = 16
_mdata$ = -460
_dims$ = -32
_tmpn$53161 = -8
_mexFunction PROC NEAR					; COMDAT

; 314  : {

	push	ebp
	mov	ebp, esp
	sub	esp, 460				; 000001ccH

; 315  :   char *filename;
; 316  :   double *pframes;
; 317  :   int *iframes;
; 318  :   void *imgbuff;
; 319  :   unsigned long *sumbuff;
; 320  :   unsigned char *bmpdata;
; 321  :   double *imgmean, *imgstd;
; 322  :   int i, j, k, nframes, npts;
; 323  :   MOVIE_DATA mdata;
; 324  :   int dims[3], status;
; 325  : 
; 326  :   // Check for proper number of arguments
; 327  :   if (nrhs != 2) {

	mov	eax, DWORD PTR _nrhs$[ebp]
	push	esi
	cmp	eax, 2
	je	SHORT $L53089

; 328  :     mexPrintf("Usage: [imgmean imgstd width heigth nframes] = vavi_mean(filename,frames)\n");

	push	OFFSET FLAT:??_C@_0EL@CBBH@Usage?3?5?$FLimgmean?5imgstd?5width?5hei@ ; `string'
	call	_mexPrintf

; 329  :     mexPrintf("Notes: frames>=0, length(frames)<66051.  ver.0.91 Sep-2003\n");

	push	OFFSET FLAT:??_C@_0DM@FEOM@Notes?3?5frames?$DO?$DN0?0?5length?$CIframes?$CJ@ ; `string'
	call	_mexPrintf

; 330  :     mexPrintf("     : frame of -1 is treated as a blank(black).\n");

	push	OFFSET FLAT:??_C@_0DC@BBNH@?5?5?5?5?5?3?5frame?5of?5?91?5is?5treated?5as@ ; `string'
	call	_mexPrintf

; 331  :     mexPrintf("     : if 'frames' is empty, then compute across all frames in the moviefile.\n");

	push	OFFSET FLAT:??_C@_0EP@HMIA@?5?5?5?5?5?3?5if?5?8frames?8?5is?5empty?0?5the@ ; `string'
	call	_mexPrintf

; 473  : 	  *mxGetPr(NFRAMES_OUT) = (double)nframes;

	add	esp, 16					; 00000010H
	pop	esi

; 474  :   }
; 475  : 
; 476  :   return;
; 477  : }

	mov	esp, ebp
	pop	ebp
	ret	0
$L53089:

; 332  :     return;
; 333  :   }
; 334  : 
; 335  :   memset(&mdata, 0, sizeof(MOVIE_DATA));
; 336  :   iframes = NULL;   imgbuff = NULL;
; 337  :   imgmean = NULL;   imgstd = NULL;
; 338  : 
; 339  :   // Get the filename
; 340  :   if (mxIsChar(FILE_IN) != 1 || mxGetM(FILE_IN) != 1) {

	mov	esi, DWORD PTR _prhs$[ebp]
	push	ebx
	push	edi
	mov	ecx, 107				; 0000006bH
	xor	eax, eax
	lea	edi, DWORD PTR _mdata$[ebp]
	rep stosd
	mov	DWORD PTR _imgstd$[ebp], eax
	mov	eax, DWORD PTR [esi]
	push	eax
	call	_mxIsChar
	add	esp, 4
	cmp	al, 1
	jne	SHORT $L53100
	mov	ecx, DWORD PTR [esi]
	push	ecx
	call	_mxGetM
	add	esp, 4
	cmp	eax, 1
	je	SHORT $L53099
$L53100:

; 341  :     mexErrMsgTxt("vavi_mean: first arg must be filename string."); 

	push	OFFSET FLAT:??_C@_0CO@IPJB@vavi_mean?3?5first?5arg?5must?5be?5fil@ ; `string'
	call	_mexErrMsgTxt
	add	esp, 4
$L53099:

; 342  :   }
; 343  :   i = (mxGetM(FILE_IN) * mxGetN(FILE_IN)) + 1;

	mov	edx, DWORD PTR [esi]
	push	edx
	call	_mxGetN
	mov	edi, eax
	mov	eax, DWORD PTR [esi]
	push	eax
	call	_mxGetM
	imul	edi, eax
	inc	edi

; 344  :   filename = mxCalloc(i, sizeof(char));

	push	1
	push	edi
	call	_mxCalloc

; 345  :   status = mxGetString(FILE_IN, filename, i);

	mov	ecx, DWORD PTR [esi]
	mov	ebx, eax
	push	edi
	push	ebx
	push	ecx
	call	_mxGetString
	add	esp, 28					; 0000001cH

; 346  :   if (status != 0) {

	test	eax, eax
	je	SHORT $L53103

; 347  :     mexWarnMsgTxt("vavi_mean: not enough space, filename string is truncated.");

	push	OFFSET FLAT:??_C@_0DL@DIKJ@vavi_mean?3?5not?5enough?5space?0?5fil@ ; `string'
	call	_mexWarnMsgTxt
	add	esp, 4
$L53103:

; 348  :   }
; 349  :   sprintf(mdata.filename,"%s",filename);

	push	ebx
	lea	edx, DWORD PTR _mdata$[ebp+172]
	push	OFFSET FLAT:??_C@_02DILL@?$CFs?$AA@	; `string'
	push	edx
	call	DWORD PTR __imp__sprintf

; 350  : 
; 351  :   // open the stream
; 352  :   if (OpenAVI(&mdata) != 0) {

	lea	eax, DWORD PTR _mdata$[ebp]
	push	eax
	call	_OpenAVI
	add	esp, 16					; 00000010H
	test	eax, eax
	je	SHORT $L53106

; 353  :     mexPrintf("\nvavi_mean: avifile=%s,frame=%d\n",
; 354  :               mdata.filename,mdata.currframe);

	mov	ecx, DWORD PTR _mdata$[ebp+4]
	lea	edx, DWORD PTR _mdata$[ebp+172]
	push	ecx
	push	edx
	push	OFFSET FLAT:??_C@_0CB@HGLO@?6vavi_mean?3?5avifile?$DN?$CFs?0frame?$DN?$CFd?6@ ; `string'
	call	_mexPrintf

; 355  :     mexErrMsgTxt("vavi_mean: OpenAVI() failed."); 

	push	OFFSET FLAT:??_C@_0BN@BKLJ@vavi_mean?3?5OpenAVI?$CI?$CJ?5failed?4?$AA@ ; `string'
	call	_mexErrMsgTxt
	add	esp, 16					; 00000010H
$L53106:

; 356  :   }
; 357  : 
; 358  :   // Get frame indices
; 359  :   nframes = mxGetN(FRAMES_IN) * mxGetM(FRAMES_IN);

	mov	eax, DWORD PTR [esi+4]
	push	eax
	call	_mxGetN
	mov	ecx, DWORD PTR [esi+4]
	mov	ebx, eax
	push	ecx
	call	_mxGetM
	imul	ebx, eax
	add	esp, 8
	mov	DWORD PTR _nframes$[ebp], ebx

; 360  :   if (nframes == 0) {

	test	ebx, ebx
	jne	SHORT $L53109

; 361  :     nframes = mdata.numframes;

	mov	esi, DWORD PTR _mdata$[ebp+16]

; 362  :     iframes = (int *)calloc(nframes,sizeof(int));

	push	4
	push	esi
	mov	DWORD PTR _nframes$[ebp], esi
	call	DWORD PTR __imp__calloc
	add	esp, 8

; 363  :     for (i = 0; i < nframes; i++)  iframes[i] = i;

	xor	ecx, ecx
	test	esi, esi
	mov	DWORD PTR _iframes$[ebp], eax
	jle	SHORT $L53114
$L53112:
	mov	DWORD PTR [eax+ecx*4], ecx
	inc	ecx
	cmp	ecx, esi
	jl	SHORT $L53112
$L53114:

; 364  :     mexPrintf("\nvavi_mean: empty 'frames' detected, now compute across all frames [%d].",nframes);

	push	esi
	push	OFFSET FLAT:??_C@_0EJ@FLLM@?6vavi_mean?3?5empty?5?8frames?8?5detec@ ; `string'
	call	_mexPrintf

; 365  :   } else {

	mov	ebx, DWORD PTR _nframes$[ebp]
	add	esp, 8
	jmp	SHORT $L53122
$L53109:

; 366  :     pframes = (double *)mxGetPr(FRAMES_IN);

	mov	edx, DWORD PTR [esi+4]
	push	edx
	call	_mxGetPr

; 367  :     iframes = (int *)calloc(nframes,sizeof(int));

	push	4
	push	ebx
	mov	edi, eax
	call	DWORD PTR __imp__calloc
	add	esp, 12					; 0000000cH

; 368  :     for (i = 0; i < nframes; i++) {

	xor	esi, esi
	test	ebx, ebx
	mov	DWORD PTR _iframes$[ebp], eax
	jle	SHORT $L53122
$L53120:

; 369  :       if (pframes[i] >= 0) {

	fld	QWORD PTR [edi+esi*8]
	fcomp	QWORD PTR __real@0000000000000000

; 370  :         iframes[i] = (int)(pframes[i] + 0.5);

	fld	QWORD PTR [edi+esi*8]
	fnstsw	ax
	and	eax, 256				; 00000100H
	jne	SHORT $L53123
	fadd	QWORD PTR __real@3fe0000000000000
	call	__ftol
	mov	ecx, DWORD PTR _iframes$[ebp]
	mov	DWORD PTR [ecx+esi*4], eax

; 371  :       } else {

	jmp	SHORT $L53121
$L53123:

; 372  :         iframes[i] = (int)(pframes[i] - 0.5);

	fsub	QWORD PTR __real@3fe0000000000000
	call	__ftol
	mov	edx, DWORD PTR _iframes$[ebp]
	mov	DWORD PTR [edx+esi*4], eax
$L53121:
	inc	esi
	cmp	esi, ebx
	jl	SHORT $L53120
$L53122:

; 373  :       }
; 374  :     }
; 375  :   }
; 376  :   if (nframes >= 66051) {

	cmp	ebx, 66051				; 00010203H
	jl	SHORT $L53127

; 377  :     mexPrintf("\nvavi_mean: num.frames[%d] should be < 66051 to avoid overflow.",nframes);

	push	ebx
	push	OFFSET FLAT:??_C@_0EA@NMIL@?6vavi_mean?3?5num?4frames?$FL?$CFd?$FN?5shoul@ ; `string'
	call	_mexPrintf
	add	esp, 8
$L53127:

; 378  :   }
; 379  : 
; 380  :   // allocate memory
; 381  :   npts = mdata.width*mdata.height*3;

	mov	eax, DWORD PTR _mdata$[ebp+12]

; 382  :   imgbuff = (void *)calloc(npts+64,sizeof(char)+2*sizeof(long));

	push	9
	imul	eax, DWORD PTR _mdata$[ebp+8]
	lea	esi, DWORD PTR [eax+eax*2]
	lea	eax, DWORD PTR [esi+64]
	push	eax
	call	DWORD PTR __imp__calloc

; 383  :   // 16byte alignment for faster access
; 384  :   bmpdata = (unsigned char *)(((unsigned)imgbuff + 15) & ~15);
; 385  :   // sumbuff store both values for mean/std.
; 386  :   // this is an attempt to improve memory access....
; 387  :   sumbuff = (unsigned long *)(((unsigned)&bmpdata[npts] + 15) & ~15);
; 388  :   //sumbuff = (unsigned long *)calloc(npts+64,sizeof(long)*2);
; 389  : #if 0
; 390  :   mexPrintf("imgbuff=%x, bmpdata=%x, sumbuff=%x\n",imgbuff,bmpdata,sumbuff);
; 391  : #endif
; 392  : 
; 393  :   k = -1000;
; 394  :   for (j = 0; j < nframes; j++) {

	mov	ecx, DWORD PTR _nframes$[ebp]
	lea	edi, DWORD PTR [eax+15]
	and	edi, -16				; fffffff0H
	mov	DWORD PTR _imgbuff$[ebp], eax
	add	esp, 8
	xor	eax, eax
	lea	ebx, DWORD PTR [edi+esi+15]
	mov	DWORD PTR _k$[ebp], -1000		; fffffc18H
	and	ebx, -16				; fffffff0H
	mov	DWORD PTR _j$[ebp], eax
	test	ecx, ecx
	jle	$L53138
$L53136:

; 395  :     mdata.currframe = iframes[j];

	mov	ecx, DWORD PTR _iframes$[ebp]
	mov	eax, DWORD PTR [ecx+eax*4]

; 396  :     if (mdata.currframe < 0 || mdata.currframe >= mdata.numframes) continue;

	test	eax, eax
	mov	DWORD PTR _mdata$[ebp+4], eax
	jl	$L53137
	cmp	eax, DWORD PTR _mdata$[ebp+16]
	jge	$L53137

; 397  :     if (mdata.currframe != k) {

	cmp	eax, DWORD PTR _k$[ebp]
	je	$L53141

; 398  :       if (GrabAVIFrame(&mdata,bmpdata) != 0) {

	lea	edx, DWORD PTR _mdata$[ebp]
	push	edi
	push	edx
	call	_GrabAVIFrame
	add	esp, 8
	test	eax, eax
	je	SHORT $L53142

; 399  :         // release AVI resources.
; 400  :         CloseAVI(&mdata);

	lea	eax, DWORD PTR _mdata$[ebp]
	push	eax
	call	_CloseAVI

; 401  :         if (iframes != NULL) { free(iframes);  iframes = NULL; }

	mov	eax, DWORD PTR _iframes$[ebp]
	add	esp, 4
	test	eax, eax
	je	SHORT $L53144
	push	eax
	call	DWORD PTR __imp__free
	add	esp, 4
	mov	DWORD PTR _iframes$[ebp], 0
$L53144:

; 402  :         if (imgbuff != NULL) { free(imgbuff);  imgbuff = NULL; }

	mov	eax, DWORD PTR _imgbuff$[ebp]
	test	eax, eax
	je	SHORT $L53147
	push	eax
	call	DWORD PTR __imp__free
	add	esp, 4
	mov	DWORD PTR _imgbuff$[ebp], 0
$L53147:

; 403  :         mexPrintf("\nvavi_mean: avifile=%s,frame=%d\n",
; 404  :                   mdata.filename,mdata.currframe);

	mov	ecx, DWORD PTR _mdata$[ebp+4]
	lea	edx, DWORD PTR _mdata$[ebp+172]
	push	ecx
	push	edx
	push	OFFSET FLAT:??_C@_0CB@HGLO@?6vavi_mean?3?5avifile?$DN?$CFs?0frame?$DN?$CFd?6@ ; `string'
	call	_mexPrintf

; 405  :         mexErrMsgTxt("vavi_mean: GrabAVIFrame() failed."); 

	push	OFFSET FLAT:??_C@_0CC@BIFP@vavi_mean?3?5GrabAVIFrame?$CI?$CJ?5failed@ ; `string'
	call	_mexErrMsgTxt
	add	esp, 16					; 00000010H
$L53142:

; 406  :       }
; 407  :       k = mdata.currframe;

	mov	eax, DWORD PTR _mdata$[ebp+4]
	mov	DWORD PTR _k$[ebp], eax
$L53141:

; 408  :     }
; 409  :     // add bmpdata, must be devided by 255 later.
; 410  :     // add bmpdata^2, must be devided by 255*255(=65025).
; 411  :     if (nlhs == 1) {

	mov	eax, DWORD PTR _nlhs$[ebp]

; 412  :       addRaw2Image(sumbuff,bmpdata,npts);

	push	esi
	push	edi
	cmp	eax, 1
	push	ebx
	jne	SHORT $L53150
	call	_addRaw2Image

; 413  :     } else {

	jmp	SHORT $L53277
$L53150:

; 414  :       procRaw2Image(sumbuff,bmpdata,npts);

	call	_procRaw2Image
$L53277:
	add	esp, 12					; 0000000cH
$L53137:

; 383  :   // 16byte alignment for faster access
; 384  :   bmpdata = (unsigned char *)(((unsigned)imgbuff + 15) & ~15);
; 385  :   // sumbuff store both values for mean/std.
; 386  :   // this is an attempt to improve memory access....
; 387  :   sumbuff = (unsigned long *)(((unsigned)&bmpdata[npts] + 15) & ~15);
; 388  :   //sumbuff = (unsigned long *)calloc(npts+64,sizeof(long)*2);
; 389  : #if 0
; 390  :   mexPrintf("imgbuff=%x, bmpdata=%x, sumbuff=%x\n",imgbuff,bmpdata,sumbuff);
; 391  : #endif
; 392  : 
; 393  :   k = -1000;
; 394  :   for (j = 0; j < nframes; j++) {

	mov	eax, DWORD PTR _j$[ebp]
	mov	ecx, DWORD PTR _nframes$[ebp]
	inc	eax
	cmp	eax, ecx
	mov	DWORD PTR _j$[ebp], eax
	jl	$L53136
$L53138:

; 415  :     }
; 416  :   }
; 417  :   CloseAVI(&mdata);  // release AVI resources.

	lea	ecx, DWORD PTR _mdata$[ebp]
	push	ecx
	call	_CloseAVI

; 418  : 
; 419  :   // get a mean image
; 420  :   imgmean = (double *)calloc(npts,sizeof(double));

	push	8
	push	esi
	call	DWORD PTR __imp__calloc
	mov	edi, eax

; 421  :   for (i = 0; i < npts; i++) {

	xor	ecx, ecx
	add	esp, 12					; 0000000cH
	xor	eax, eax
	cmp	esi, ecx
	jle	SHORT $L53156
	fild	DWORD PTR _nframes$[ebp]
$L53154:

; 422  :     imgmean[i] = (double)sumbuff[i] / (double)nframes / 255.0;

	mov	edx, DWORD PTR [ebx+eax*4]
	mov	DWORD PTR -8+[ebp+4], ecx
	mov	DWORD PTR -8+[ebp], edx
	inc	eax
	fild	QWORD PTR -8+[ebp]
	cmp	eax, esi
	fdiv	ST(0), ST(1)
	fmul	QWORD PTR __real@3f70101010101010
	fstp	QWORD PTR [edi+eax*8-8]
	jl	SHORT $L53154
	fstp	ST(0)
$L53156:

; 423  :   }
; 424  :   // get a std image
; 425  :   if (nlhs > 1) {

	cmp	DWORD PTR _nlhs$[ebp], 1
	jle	SHORT $L53169

; 426  :     double tmpv, tmpn, tmpn2;
; 427  :     imgstd  = (double *)calloc(npts,sizeof(double));

	push	8
	push	esi
	call	DWORD PTR __imp__calloc

; 428  :     tmpn  = (double)nframes;

	fild	DWORD PTR _nframes$[ebp]

; 429  :     tmpn2 = 0;
; 430  :     if (nframes > 1) tmpn2 = tmpn / (tmpn - 1.0);

	mov	ecx, DWORD PTR _nframes$[ebp]
	add	esp, 8
	cmp	ecx, 1
	mov	DWORD PTR _imgstd$[ebp], eax
	fstp	QWORD PTR _tmpn$53161[ebp]
	fld	QWORD PTR __real@0000000000000000
	jle	SHORT $L53166
	fstp	ST(0)
	fld	QWORD PTR _tmpn$53161[ebp]
	fsub	QWORD PTR __real@3ff0000000000000
	fdivr	QWORD PTR _tmpn$53161[ebp]
$L53166:

; 431  :     tmpn = tmpn * 65025.0;        // 255*255=65025.

	fld	QWORD PTR _tmpn$53161[ebp]
	fmul	QWORD PTR __real@40efc02000000000

; 432  :     for (i = 0, j = npts; i < npts; i++, j++) {

	test	esi, esi
	jle	SHORT $L53269
	fdivr	QWORD PTR __real@3ff0000000000000
	mov	ecx, edi
	lea	ebx, DWORD PTR [ebx+esi*4]
	sub	ecx, eax
$L53167:

; 433  :       tmpv = (double)sumbuff[j] / tmpn - imgmean[i]*imgmean[i];
; 434  :       imgstd[i] = sqrt(tmpv * tmpn2);

	mov	edx, DWORD PTR [ebx]
	mov	DWORD PTR -8+[ebp+4], 0
	fld	QWORD PTR [ecx+eax]
	mov	DWORD PTR -8+[ebp], edx
	add	ebx, 4
	fild	QWORD PTR -8+[ebp]
	add	eax, 8
	dec	esi
	fmul	ST(0), ST(2)
	fld	ST(1)
	fmul	ST(0), ST(2)
	fsubp	ST(1), ST(0)
	fmul	ST(0), ST(3)
	fsqrt
	fstp	QWORD PTR [eax-8]
	fstp	ST(0)
	jne	SHORT $L53167
$L53269:

; 431  :     tmpn = tmpn * 65025.0;        // 255*255=65025.

	fstp	ST(0)
	fstp	ST(0)
$L53169:

; 435  :     }
; 436  :   }
; 437  :   if (iframes != NULL) { free(iframes);  iframes = NULL; }

	mov	eax, DWORD PTR _iframes$[ebp]
	mov	ebx, DWORD PTR __imp__free
	test	eax, eax
	je	SHORT $L53172
	push	eax
	call	ebx
	add	esp, 4
$L53172:

; 438  :   if (imgbuff != NULL) { free(imgbuff);  imgbuff = NULL; }

	mov	eax, DWORD PTR _imgbuff$[ebp]
	test	eax, eax
	je	SHORT $L53175
	push	eax
	call	ebx
	add	esp, 4
$L53175:

; 439  :   //free(sumbuff);
; 440  : 
; 441  : 
; 442  :   // set dimenstion
; 443  :   dims[0] = mdata.height;  // height

	mov	eax, DWORD PTR _mdata$[ebp+12]

; 444  :   dims[1] = mdata.width;   // width

	mov	ecx, DWORD PTR _mdata$[ebp+8]

; 445  :   dims[2] = 3;             // color: RGB
; 446  : 
; 447  :   IMGMEAN_OUT = mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);

	push	0
	lea	edx, DWORD PTR _dims$[ebp]
	push	6
	push	edx
	push	3
	mov	DWORD PTR _dims$[ebp], eax
	mov	DWORD PTR _dims$[ebp+4], ecx
	mov	DWORD PTR _dims$[ebp+8], 3
	call	_mxCreateNumericArray

; 448  :   // Matlab stores image as a three-dimensional (m-by-n-by-3) array
; 449  :   alignImage4Matlab((double *)mxGetPr(IMGMEAN_OUT),
; 450  :                     imgmean,mdata.width,mdata.height);

	mov	ecx, DWORD PTR _mdata$[ebp+12]
	mov	edx, DWORD PTR _mdata$[ebp+8]
	mov	esi, DWORD PTR _plhs$[ebp]
	add	esp, 16					; 00000010H
	push	ecx
	push	edx
	push	edi
	push	eax
	mov	DWORD PTR [esi], eax
	call	_mxGetPr
	add	esp, 4
	push	eax
	call	_alignImage4Matlab
	add	esp, 16					; 00000010H

; 451  :   if (imgmean != NULL) { free(imgmean);  imgmean = NULL; }

	test	edi, edi
	je	SHORT $L53179
	push	edi
	call	ebx
	add	esp, 4
$L53179:

; 452  : 
; 453  :   if (nlhs > 1) {

	cmp	DWORD PTR _nlhs$[ebp], 1
	jle	SHORT $L53274

; 454  :     IMGSTD_OUT = mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);

	push	0
	lea	eax, DWORD PTR _dims$[ebp]
	push	6
	push	eax
	push	3
	call	_mxCreateNumericArray

; 455  :     alignImage4Matlab((double *)mxGetPr(IMGSTD_OUT),
; 456  :                       imgstd,mdata.width,mdata.height);

	mov	ecx, DWORD PTR _mdata$[ebp+12]
	mov	edx, DWORD PTR _mdata$[ebp+8]
	mov	edi, DWORD PTR _imgstd$[ebp]
	add	esp, 16					; 00000010H
	mov	DWORD PTR [esi+4], eax
	push	ecx
	push	edx
	push	edi
	push	eax
	call	_mxGetPr
	add	esp, 4
	push	eax
	call	_alignImage4Matlab
	add	esp, 16					; 00000010H
	jmp	SHORT $L53181
$L53274:
	mov	edi, DWORD PTR _imgstd$[ebp]
$L53181:

; 457  :   }
; 458  :   if (imgstd  != NULL) { free(imgstd);   imgstd = NULL;  }

	test	edi, edi
	je	SHORT $L53184
	push	edi
	call	ebx
	add	esp, 4
$L53184:

; 459  :   
; 460  :   // width
; 461  :   if (nlhs >= 3) {

	mov	eax, DWORD PTR _nlhs$[ebp]
	pop	edi
	cmp	eax, 3
	pop	ebx
	jl	SHORT $L53186

; 462  :     WIDTH_OUT = mxCreateDoubleMatrix(1, 1, mxREAL);

	push	0
	push	1
	push	1
	call	_mxCreateDoubleMatrix

; 463  :     *mxGetPr(WIDTH_OUT) = (double)mdata.width;

	fild	DWORD PTR _mdata$[ebp+8]
	push	eax
	mov	DWORD PTR [esi+8], eax
	fstp	QWORD PTR -8+[ebp]
	call	_mxGetPr
	mov	ecx, DWORD PTR -8+[ebp]
	mov	edx, DWORD PTR -8+[ebp+4]
	mov	DWORD PTR [eax], ecx
	add	esp, 16					; 00000010H
	mov	DWORD PTR [eax+4], edx
$L53186:

; 464  :   }
; 465  :   // height
; 466  :   if (nlhs >= 4) {

	cmp	DWORD PTR _nlhs$[ebp], 4
	jl	SHORT $L53188

; 467  : 	  HEIGHT_OUT = mxCreateDoubleMatrix(1, 1, mxREAL);

	push	0
	push	1
	push	1
	call	_mxCreateDoubleMatrix

; 468  : 	  *mxGetPr(HEIGHT_OUT) = (double)mdata.height;

	fild	DWORD PTR _mdata$[ebp+12]
	push	eax
	mov	DWORD PTR [esi+12], eax
	fstp	QWORD PTR -8+[ebp]
	call	_mxGetPr
	mov	ecx, DWORD PTR -8+[ebp]
	mov	edx, DWORD PTR -8+[ebp+4]
	mov	DWORD PTR [eax], ecx
	add	esp, 16					; 00000010H
	mov	DWORD PTR [eax+4], edx
$L53188:

; 469  :   }
; 470  :   // num. of frames added.
; 471  :   if (nlhs >= 5) {

	cmp	DWORD PTR _nlhs$[ebp], 5
	jl	SHORT $L53190

; 472  : 	  NFRAMES_OUT = mxCreateDoubleMatrix(1, 1, mxREAL);

	push	0
	push	1
	push	1
	call	_mxCreateDoubleMatrix

; 473  : 	  *mxGetPr(NFRAMES_OUT) = (double)nframes;

	push	eax
	mov	DWORD PTR [esi+16], eax
	call	_mxGetPr
	fild	DWORD PTR _nframes$[ebp]
	add	esp, 16					; 00000010H
	fstp	QWORD PTR [eax]
$L53190:
	pop	esi

; 474  :   }
; 475  : 
; 476  :   return;
; 477  : }

	mov	esp, ebp
	pop	ebp
	ret	0
_mexFunction ENDP
_TEXT	ENDS
PUBLIC	_DllMain@12
EXTRN	_InitAVILib:NEAR
EXTRN	_ExitAVILib:NEAR
; Function compile flags: /Ogt
;	COMDAT _DllMain@12
_TEXT	SEGMENT
_reason$ = 12
_DllMain@12 PROC NEAR					; COMDAT

; 486  : {

	push	ebp
	mov	ebp, esp

; 487  :   switch (reason) {

	mov	eax, DWORD PTR _reason$[ebp]
	sub	eax, 0
	je	SHORT $L53205
	dec	eax
	jne	SHORT $L53279

; 488  :   case DLL_PROCESS_ATTACH:
; 489  :     //printf("process_attach\n");
; 490  :     InitAVILib();

	call	_InitAVILib

; 501  :     break;
; 502  :   }
; 503  : 	return TRUE;

	mov	eax, 1

; 504  : }

	pop	ebp
	ret	12					; 0000000cH
$L53205:

; 491  :     break;
; 492  :   case DLL_THREAD_ATTACH:
; 493  :     //printf("thread_attach\n");
; 494  :     break;
; 495  :   case DLL_THREAD_DETACH:
; 496  :     //printf("thread_detach\n");
; 497  :     break;
; 498  :   case DLL_PROCESS_DETACH:
; 499  :     //printf("process_detach\n");
; 500  :     ExitAVILib();

	call	_ExitAVILib
$L53279:

; 501  :     break;
; 502  :   }
; 503  : 	return TRUE;

	mov	eax, 1

; 504  : }

	pop	ebp
	ret	12					; 0000000cH
_DllMain@12 ENDP
_TEXT	ENDS
END
