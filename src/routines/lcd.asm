;-------------------------------------------------------------------------------
ClearScreens:
	call	ClearVBuf1
ClearVBuf2:
	ld	hl,vBuf2
	jr	+_
ClearVBuf1:
	ld	hl,vBuf1
_:	ld	a,$FF
	ld	bc,lcdWidth*lcdHeight
	jp	_MemSet

;-------------------------------------------------------------------------------
CopyHL1555Palette:
	ld	hl,$E30200    ; palette mem
	ld	b,0
_:	ld	d,b
	ld	a,b
	and	a,%11000000
	srl	d
	rra
	ld	e,a
	ld	a,%00011111
	and	a,b
	or	a,e
	ld	(hl),a
	inc	hl
	ld	(hl),d
	inc	hl
	inc	b
	jr	nz,-_
	ret

;-------------------------------------------------------------------------------
_Sprite8bpp:
; hl -> sprite
; bc = xy
	push	hl
	or	a,a
	sbc	hl,hl
	ld	l,b
	add	hl,hl
	ld	de,vBuf2
	add	hl,de
	ld	b,lcdWidth/2
	mlt	bc
	add	hl,bc
	add	hl,bc				; hl -> start draw location
	ld	b,0
	ex	de,hl
	pop	hl
	ld	a,(hl)
	ld	(NoClipSprLineNext),a		; a = width
	inc	hl
	ld	a,(hl)				; a = height
	inc	hl
	ld	ix,0
NoClipSprLineNext =$+1
_:	ld	c,0
	add	ix,de
	lea	de,ix
	ldir
	ld	de,lcdWidth
	dec	a
	jr	nz,-_
	ret

;-------------------------------------------------------------------------------
_Sprite8bpp_2x:
; hl -> sprite
; bc = xy
	ld	a,(hl) 				; width
	ld	(SpriteWidth_2x_SMC),a
	push	hl
	ld	de,0
	add	a,a
	ld	e,a
	ld	hl,lcdWidth
	sbc	hl,de
	ld	(SpriteWidth255_2x_SMC),hl
	pop	hl
	inc	hl
	push	hl
	ld	l,c
	ld	h,lcdWidth/2
	mlt	hl
	add	hl,hl
	ld	de,vBuf2
	add	hl,de
	push	hl
	sbc	hl,hl
	ld	l,b
	add	hl,hl
	pop	de
	add	hl,de  				; Add X ; Returns hl -> sprite data, a = sprite height
	ex	de,hl
	pop	hl
	ld	b,(hl)
	inc	hl
InLoop8bpp_2x:
	push	bc
SpriteWidth_2x_SMC: =$+1
	ld	bc,0
	push	de				; save pointer to current line
_:	ld	a,(hl)
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de
	inc	hl
	dec	bc
	ld 	a,b
	or	a,c
	jr	nz,-_
	ex	de,hl
SpriteWidth255_2x_SMC: =$+1
	ld	bc,0				; Increment amount per line
	add	hl,bc				; HL->next place to draw, DE->location to get from
	push	de
	pop	ix				; ix->location to get from
	ex	de,hl				; hl
	ld	hl,(SpriteWidth_2x_SMC)
	add	hl,hl
	ld	b,h
	ld	c,l				; BC=real size to copy
	pop	hl				; HL->pervious line
	ldir
	ex	de,hl
	ld	bc,(SpriteWidth255_2x_SMC)
	add	hl,bc
	lea	de,ix
	ex	de,hl
	pop	bc
	djnz	InLoop8bpp_2x
	ret

;-------------------------------------------------------------------------------
; Common Sprites
;-------------------------------------------------------------------------------
directorySprite:
 .db 16,16
 .db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
 .db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
 .db 255,255,08Bh,083h,083h,083h,083h,083h,083h,083h,082h,082h,083h,08Bh,255,255
 .db 255,0A3h,0ABh,0ACh,0ACh,0ACh,0ACh,0ACh,0ACh,0ACh,0ACh,0ACh,0ACh,0A3h,08Bh,255
 .db 083h,0ABh,0CCh,0A3h,0A3h,0A3h,0A3h,0A2h,0A2h,082h,082h,082h,08Bh,0ABh,083h,08Bh
 .db 083h,0CDh,0A3h,0A2h,0A2h,0A2h,082h,082h,082h,082h,082h,082h,082h,083h,0ACh,082h
 .db 083h,0EEh,0F5h,0EDh,0EDh,0EDh,0EDh,0EDh,0EDh,0EDh,0ECh,0ECh,0ECh,0ECh,0EDh,082h
 .db 083h,0EDh,0EDh,0EDh,0ECh,0ECh,0ECh,0ECh,0CCh,0CCh,0CCh,0CBh,0CBh,0CBh,0ECh,082h
 .db 083h,0EDh,0EDh,0ECh,0ECh,0ECh,0ECh,0CCh,0CCh,0CBh,0CBh,0CBh,0CBh,0CBh,0ECh,082h
 .db 083h,0EDh,0ECh,0ECh,0ECh,0CCh,0CCh,0CCh,0CBh,0CBh,0CBh,0CBh,0CBh,0C3h,0CCh,082h
 .db 083h,0EDh,0ECh,0CCh,0CCh,0CCh,0CBh,0CBh,0CBh,0CBh,0CBh,0C3h,0C3h,0C3h,0CCh,082h
 .db 083h,0EDh,0ECh,0CCh,0CBh,0CBh,0CBh,0CBh,0CBh,0C3h,0C3h,0C3h,0C3h,0C3h,0CCh,082h
 .db 082h,0EDh,0CCh,0CBh,0CBh,0CBh,0CBh,0CBh,0C3h,0C3h,0C3h,0C3h,0C3h,0C2h,0CCh,082h
 .db 082h,0CDh,0EDh,0EDh,0ECh,0ECh,0ECh,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,082h
 .db 08Bh,082h,082h,082h,082h,082h,082h,082h,082h,082h,082h,082h,082h,082h,082h,08Ah
 .db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
asmFileSprite:
 .db 16,16
 .db 255,255,255,093,125,125,125,125,125,125,019,019,255,255,255,255
 .db 255,255,255,125,255,255,223,223,223,223,125,019,019,255,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,125,019,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,255,125,019,255
 .db 255,255,255,125,255,255,255,255,223,223,223,125,191,191,125,019
 .db 255,255,255,125,255,255,255,255,255,223,223,223,223,223,125,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,255,160,160,160,255,160,160,160,255,160,255,160,255,000,019
 .db 000,255,160,255,160,255,160,255,255,255,160,160,160,255,000,019
 .db 000,255,160,160,160,255,255,255,160,255,160,255,160,255,000,019
 .db 000,255,160,255,160,255,160,160,160,255,160,255,160,255,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 255,255,255,019,255,255,255,255,255,255,255,255,255,255,255,019
 .db 255,255,255,018,019,019,019,019,019,019,019,019,019,019,019,018
cFileSprite:
 .db 16,16
 .db 255,255,255,093,125,125,125,125,125,125,019,019,255,255,255,255
 .db 255,255,255,125,255,255,223,223,223,223,125,019,019,255,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,125,019,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,255,125,019,255
 .db 255,255,255,125,255,255,255,255,223,223,223,125,191,191,125,019
 .db 255,255,255,125,255,255,255,255,255,223,223,223,223,223,125,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,255,255,255,255,255,019,019,019,255,255,255,255,255,000,019
 .db 000,255,255,255,255,255,019,255,255,255,255,255,255,255,000,019
 .db 000,255,255,255,255,255,019,255,255,255,255,255,255,255,000,019
 .db 000,255,255,255,255,255,019,019,019,255,255,255,255,255,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 255,255,255,019,255,255,255,255,255,255,255,255,255,255,255,019
 .db 255,255,255,018,019,019,019,019,019,019,019,019,019,019,019,018
ICEFileSprite:
 .db 16,16
 .db 255,255,255,093,125,125,125,125,125,125,019,019,255,255,255,255
 .db 255,255,255,125,255,255,223,223,223,223,125,019,019,255,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,125,019,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,255,125,019,255
 .db 255,255,255,125,255,255,255,255,223,223,223,125,191,191,125,019
 .db 255,255,255,125,255,255,255,255,255,223,223,223,223,223,125,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,255,005,005,005,255,005,005,005,255,005,005,005,255,000,019
 .db 000,255,255,005,255,255,005,255,255,255,005,255,255,255,000,019
 .db 000,255,255,005,255,255,005,255,255,255,005,005,255,255,000,019
 .db 000,255,005,005,005,255,005,005,005,255,005,005,005,255,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 255,255,255,019,255,255,255,255,255,255,255,255,255,255,255,019
 .db 255,255,255,018,019,019,019,019,019,019,019,019,019,019,019,018
AppFileSprite:
 .db 16,16
 .db 255,255,255,093,125,125,125,125,125,125,019,019,255,255,255,255
 .db 255,255,255,125,255,255,223,223,223,223,125,019,019,255,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,125,019,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,255,125,019,255
 .db 255,255,255,125,255,255,255,255,223,223,223,125,191,191,125,019
 .db 255,255,255,125,255,255,255,255,255,223,223,223,223,223,125,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,255,005,005,005,255,005,005,005,255,005,005,005,255,000,019
 .db 000,255,005,255,005,255,005,255,005,255,005,255,005,255,000,019
 .db 000,255,005,005,005,255,005,005,005,255,005,005,005,255,000,019
 .db 000,255,005,255,005,255,005,255,255,255,005,255,255,255,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 255,255,255,019,255,255,255,255,255,255,255,255,255,255,255,019
 .db 255,255,255,018,019,019,019,019,019,019,019,019,019,019,019,018
basicFileSprite:
 .db 16,16
 .db 255,255,255,093,125,125,125,125,125,125,019,019,255,255,255,255
 .db 255,255,255,125,255,255,223,223,223,223,125,019,019,255,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,125,019,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,255,125,019,255
 .db 255,255,255,125,255,255,255,255,223,223,223,125,191,191,125,019
 .db 255,255,255,125,255,255,255,255,255,223,223,223,223,223,125,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,255,255,255,227,227,227,255,227,227,227,255,255,255,000,019
 .db 000,255,255,255,255,227,255,255,255,227,255,255,255,255,000,019
 .db 000,255,255,255,255,227,255,255,255,227,255,255,255,255,000,019
 .db 000,255,255,255,255,227,255,255,227,227,227,255,255,255,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 255,255,255,019,255,255,255,255,255,255,255,255,255,255,255,019
 .db 255,255,255,018,019,019,019,019,019,019,019,019,019,019,019,018
lockedSprite:
 .db 6,8
 .db 255,75,75,75,75,255
 .db 255,75,255,255,75,255
 .db 255,75,255,255,75,255
 .db 75,75,75,75,75,75
 .db 75,228,228,228,228,75
 .db 75,228,228,228,228,75
 .db 75,228,228,228,228,75
 .db 75,75,75,75,75,75
archivedSprite:
 .db 6,8
 .db 75,75,75,75,75,75
 .db 75,255,75,255,255,75
 .db 75,255,255,75,255,75
 .db 75,255,75,255,255,75
 .db 75,228,228,75,228,75
 .db 75,228,75,228,228,75
 .db 75,228,228,75,228,75
 .db 75,75,75,75,75,75
batterySprite:
 .db 6,8
 .db 000,000,000,000,000,000
 .db 000,037,037,037,037,000
 .db 000,037,037,037,037,000
 .db 000,037,037,037,037,000
 .db 000,037,037,037,037,000
 .db 000,037,037,037,037,000
 .db 000,037,037,037,037,000
 .db 000,000,000,000,000,000
