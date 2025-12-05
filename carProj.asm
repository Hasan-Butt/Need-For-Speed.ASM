; ============================================
; 			  RACE CAR GAME
; ============================================
; Developers: 
; - Muhammad Hasan Butt  24L-3022
; - Kabeer Ahmed Shahzeb 24L-3087
; ============================================
org 100h

jmp start

section .data
	; Screen constants
    SCREEN_WIDTH equ 320
    SCREEN_HEIGHT equ 200
	BUFFER_SEG equ 0x7000
    VIDEO_SEG equ 0xA000
	 ; Lane positions (X coordinates for center of each lane)
    LANE_LEFT equ 106      
    LANE_CENTER equ 160   
    LANE_RIGHT equ 213
    
    LANE_CHANGE_SPEED equ 5 ; Pixels to move per frame
	
; ============================================================	
; 					Scrolling variables
; ============================================================
	ScrollOffset dw 0          ; Current scroll position (0-19)
	ScrollSpeed dw 5           ; Pixels to scroll per frame
	RoadLineOffset dw 0        ; For animated road lines
	TreeScrollY1 dw 0          ; Vertical scroll for trees
	TreeScrollY2 dw 0
	StoneScrollY1 dw 0         ; Vertical scroll for stones
	StoneScrollY2 dw 0
	
	ScoreText 	dw 11 * 320 + 255
				db 15, 1, 0, "SCORE:", 0
	ScoreBuffer dw 11 * 320 + 291
				db 15, 1, 0, "0", 0, 0, 0
	
 ;============================================
 ; 			   Future sprites
 ;============================================
	pal_filename   db 'Pallete.PAL', 0
	intro_image    db 'IntroSc2.RAW', 0
	gameover_image db 'overSC2.RAW', 0
	car_width 	   dw 64
    car_height     dw 64
	tree1_filename db 'tree2Img.RAW',0
	tree1_width    dw 32
	tree1_height   dw 32
	tree2_filename db 'treeImg.RAW', 0
	tree2_width	   dw 64
	tree2_height   dw 64
	
	; Stone initial Y positions
	stone1_y dw 40
	stone2_y dw 120
	stone3_y dw 180
	stone4_y dw 50
    
    ; Road constants
    ROAD_LEFT equ 80         
    ROAD_WIDTH equ 160      
    ROAD_RIGHT equ 240      
    LANE_WIDTH equ 53
    
; =================================================
;  				 Defined Colors
; =================================================
    COLOR_SKY equ 3          ; Cyan sky
    COLOR_GRASS equ 2        ; Green grass
    COLOR_ROAD equ 8         ; Dark gray road
    COLOR_LINES equ 15       ; White road lines
	COLOR_ROAD_EDGES equ 14  ; Yellow road edges
    COLOR_CAR_BODY equ 12    ; Red car
    COLOR_CAR_ROOF equ 4     ; Dark red roof
    COLOR_WINDOW equ 9       ; Light blue window
    COLOR_WHEEL equ 0        ; Black wheels
    COLOR_TREE equ 10        ; Green tree
    COLOR_TRUNK equ 6        ; Brown trunk
    COLOR_STONE_DARK equ 8      ; Dark gray
    COLOR_STONE_MID equ 7       ; Light gray  
    COLOR_STONE_LIGHT equ 15    ; White highlight
	
; ==========================================================
;				    Loading Screen
; ==========================================================
txt1 dw (100 - 3 * 9) * 320 + (160 - 19 * 3)
	 db 2, 0, 1, "NEED FOR SPEED: ASM", 0
txt2 dw (100 - 1 * 9) * 320 + (160 - 17 * 3)
	 db 4, 0, 1, "MADE BY:", 0
txt3 dw (100 + 0 * 9) * 320 + (160 - 23 * 3)
	 db 3, 0, 1, "24L-3022 _ MUHAMMAD HASAN BUTT", 0
txt4 dw (100 + 1 * 9) * 320 + (160 - 23 * 3)
	 db 3, 0, 1, "24L-3087 _ KABEER AHMED SHAHZEB", 0

txt5 dw (100 - 2 * 9) * 320 + (160 - 12 * 3)
	 db 3, 0, 0, "LOADING", 0
	 dw (100 - 2 * 9) * 320 + (160 + 2 * 3)
	 db 3, 0, 0, ".", 0
	 dw (100 - 2 * 9) * 320 + (160 + 2 * 3)
	 db 5, 0, 0, "   ", 0
	 dw (100 - 2 * 9) * 320 + (160 + 8 * 3)
	 db 2, 0, 0, "  0%", 0
	  
loadingDelay db 1, 20, 2, 10, 4, 5, 5, 4, 10, 2, 20, 1, 1, 20, 4, 5, 5, 4, 1, 20, 4, 5, 5, 4

; BOX FORMAT
; boxn: db y1, x1, y2, x2, [fill color], [border color]
box1 dw 98, 100, 107, 218, 0, 1
	 dw 100, 130, 108, 140, 2, 2
	 dw 100, 142, 108, 152, 2, 2
	 dw 100, 154, 108, 164, 2, 2
	 dw 100, 166, 108, 176, 2, 2
	 dw 100, 178, 108, 188, 2, 2

minicar dw 100 * 320 + 102
	db 15, 15, 48, 48,  0, 32, 48, 48, 48, 32,  0,  0,  0,  0,  0
	db 15, 15, 48,  2, 32, 52, 44, 44, 44, 52, 32, 48, 48,  0,  0
	db 15, 32, 48, 32, 52, 32, 44, 44, 44, 32, 52, 44, 48, 44, 32
	db 15, 32, 48, 48, 32, 32, 48, 48, 48, 32, 32, 44, 48, 48, 32
	db 15, 32,  2,  2, 32,  2,  2, 32,  2, 48, 32, 48, 48, 48, 32
	db 15, 32, 32, 32,  2,  2,  2, 32, 32,  2,  2,  2,  2, 44, 32
	db 15, 28, 24, 16, 16, 16,  2,  2,  2,  2, 16, 16, 16, 24, 28
	db 15, 20, 20, 16, 20, 16, 20, 20, 20, 20, 16, 20, 16, 20, 20
	
; ============================================
; 		HEART SPRITE DATA (8x8 pixels)
; ============================================
heart_sprite	db 0,  12, 12, 0,  0,  12, 12, 0     
				db 12, 4,  4,  12, 12, 4,  4,  12    
				db 12, 4,  4,  4,  4,  4,  4,  12    
				db 12, 4,  4,  4,  4,  4,  4,  12    
				db 0,  12, 4,  4,  4,  4,  12, 0     
				db 0,  0,  12, 4,  4,  12, 0,  0     
				db 0,  0,  0,  12, 12, 0,  0,  0     
				db 0,  0,  0,  0,  0,  0,  0,  0     
	
lives_label dw 10 * 320 + 8      ; Position
            db 15, 2, 0, "LIVES:", 0
	
;=======================================================================	
; 8x8 font for digits '0' to '9' (ASCII 48 to 57)
; Each char: 8 bytes = 8 rows, each byte = 8 bits (MSB = leftmost pixel)
;=======================================================================
char5x7	db 0, 0, 0, 0, 0 ;
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0

		db 0, 0, 1, 0, 0 ; !
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 1, 0, 0

		db 0, 1, 0, 1, 0 ; "
		db 0, 1, 0, 1, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0

		db 0, 1, 0, 1, 0 ; #
		db 0, 1, 0, 1, 0
		db 1, 1, 1, 1, 1
		db 0, 1, 0, 1, 0
		db 1, 1, 1, 1, 1
		db 0, 1, 0, 1, 0
		db 0, 1, 0, 1, 0

		db 0, 0, 1, 0, 0 ; $
		db 0, 1, 1, 1, 1
		db 1, 0, 1, 0, 0
		db 0, 1, 1, 1, 0
		db 0, 0, 1, 0, 1
		db 1, 1, 1, 1, 0
		db 0, 0, 1, 0, 0

		db 1, 1, 0, 0, 0 ; %
		db 1, 1, 0, 0, 1
		db 0, 0, 0, 1, 0
		db 0, 0, 1, 0, 0
		db 0, 1, 0, 0, 0
		db 1, 0, 0, 1, 1
		db 0, 0, 0, 1, 1

		db 0, 1, 1, 1, 0 ; &
		db 1, 0, 0, 1, 0
		db 1, 0, 1, 0, 0
		db 0, 1, 0, 0, 0
		db 1, 0, 1, 0, 1
		db 1, 0, 0, 1, 0
		db 0, 1, 1, 0, 1

		db 0, 0, 1, 0, 0 ; '
		db 0, 0, 1, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0

		db 0, 0, 0, 1, 0 ; (
		db 0, 0, 1, 0, 0
		db 0, 1, 0, 0, 0
		db 0, 1, 0, 0, 0
		db 0, 1, 0, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 0, 1, 0

		db 0, 1, 0, 0, 0 ; )
		db 0, 0, 1, 0, 0
		db 0, 0, 0, 1, 0
		db 0, 0, 0, 1, 0
		db 0, 0, 0, 1, 0
		db 0, 0, 1, 0, 0
		db 0, 1, 0, 0, 0

		db 0, 0, 0, 0, 0 ; *
		db 1, 0, 1, 0, 1
		db 0, 1, 1, 1, 0
		db 1, 1, 1, 1, 1
		db 0, 1, 1, 1, 0
		db 1, 0, 1, 0, 1
		db 0, 0, 0, 0, 0

		db 0, 0, 0, 0, 0 ; +
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 1, 1, 1, 1, 1
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 0, 0, 0

		db 0, 0, 0, 0, 0 ; ,
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 1, 0, 0, 0

		db 0, 0, 0, 0, 0 ; -
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 1, 1, 1, 1, 1
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0

		db 0, 0, 0, 0, 0 ; .
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 1, 0, 0

		db 0, 0, 0, 0, 0 ; /
		db 0, 0, 0, 0, 1
		db 0, 0, 0, 1, 0
		db 0, 0, 1, 0, 0
		db 0, 1, 0, 0, 0
		db 1, 0, 0, 0, 0
		db 0, 0, 0, 0, 0

num5x7	db 0, 1, 1, 1, 0 ; 0
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 1, 1
		db 1, 0, 1, 0, 1
		db 1, 1, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 0, 1, 1, 1, 0

		db 0, 0, 1, 0, 0 ; 1
		db 0, 1, 1, 0, 0
		db 1, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 1, 1, 1, 1, 1

		db 0, 1, 1, 1, 0 ; 2
		db 1, 0, 0, 0, 1
		db 0, 0, 0, 0, 1
		db 0, 0, 1, 1, 0
		db 0, 1, 0, 0, 0
		db 1, 0, 0, 0, 0
		db 1, 1, 1, 1, 1

		db 0, 1, 1, 1, 0 ; 3
		db 1, 0, 0, 0, 1
		db 0, 0, 0, 0, 1
		db 0, 0, 1, 1, 0
		db 0, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 0, 1, 1, 1, 0

		db 0, 0, 0, 1, 0 ; 4
		db 0, 0, 1, 1, 0
		db 0, 1, 0, 1, 0
		db 1, 0, 0, 1, 0
		db 1, 1, 1, 1, 1
		db 0, 0, 0, 1, 0
		db 0, 0, 0, 1, 0

		db 1, 1, 1, 1, 1 ; 5
		db 1, 0, 0, 0, 0
		db 1, 1, 1, 1, 0
		db 0, 0, 0, 0, 1
		db 0, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 0, 1, 1, 1, 0

		db 0, 1, 1, 1, 0 ; 6
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 0
		db 1, 1, 1, 1, 0
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 0, 1, 1, 1, 0

		db 1, 1, 1, 1, 1 ; 7
		db 0, 0, 0, 0, 1
		db 0, 0, 0, 1, 0
		db 0, 0, 1, 0, 0
		db 0, 1, 1, 1, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0

		db 0, 1, 1, 1, 0 ; 8
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 0, 1, 1, 1, 0
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 0, 1, 1, 1, 0

		db 0, 1, 1, 1, 0 ; 9
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 0, 1, 1, 1, 1
		db 0, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 0, 1, 1, 1, 0

		db 0, 0, 0, 0, 0 ; :
		db 0, 0, 1, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 0, 0, 0

		db 0, 0, 0, 0, 0 ; ;
		db 0, 0, 1, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 1, 0, 0, 0

		db 0, 0, 0, 0, 0 ; <
		db 0, 0, 0, 1, 0
		db 0, 0, 1, 0, 0
		db 0, 1, 0, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 0, 1, 0
		db 0, 0, 0, 0, 0

		db 0, 0, 0, 0, 0 ; =
		db 0, 0, 0, 0, 0
		db 1, 1, 1, 1, 1
		db 0, 0, 0, 0, 0
		db 1, 1, 1, 1, 1
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0

		db 0, 0, 0, 0, 0 ; >
		db 0, 1, 0, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 0, 1, 0
		db 0, 0, 1, 0, 0
		db 0, 1, 0, 0, 0
		db 0, 0, 0, 0, 0

		db 0, 1, 1, 1, 0 ; ?
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 0, 0, 0, 1, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 1, 0, 0

		db 0, 1, 1, 1, 0 ; @
		db 1, 0, 0, 0, 1
		db 1, 0, 1, 1, 1
		db 1, 0, 1, 0, 1
		db 1, 0, 1, 1, 1
		db 1, 0, 0, 0, 0
		db 0, 1, 1, 1, 0

		db 0, 1, 1, 1, 0 ; A
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 1, 1, 1, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1

		db 1, 1, 1, 1, 0 ; B
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 1, 1, 1, 0
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 1, 1, 1, 0

		db 0, 1, 1, 1, 0 ; C
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 0, 1
		db 0, 1, 1, 1, 0

		db 1, 1, 1, 1, 0 ; D
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 1, 1, 1, 0

		db 1, 1, 1, 1, 1 ; E
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 0, 0
		db 1, 1, 1, 1, 0
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 0, 0
		db 1, 1, 1, 1, 1

		db 1, 1, 1, 1, 1 ; F
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 0, 0
		db 1, 1, 1, 1, 0
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 0, 0

		db 0, 1, 1, 1, 0 ; G
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 1, 1
		db 1, 0, 0, 0, 1
		db 0, 1, 1, 1, 0

		db 1, 0, 0, 0, 1 ; H
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 1, 1, 1, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1

		db 1, 1, 1, 1, 1 ; I
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 1, 1, 1, 1, 1

		db 1, 1, 1, 1, 1 ; J
		db 0, 0, 0, 0, 1
		db 0, 0, 0, 0, 1
		db 0, 0, 0, 0, 1
		db 0, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 0, 1, 1, 1, 0

		db 1, 0, 0, 0, 1 ; K
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 1, 0
		db 1, 1, 1, 0, 0
		db 1, 0, 0, 1, 0
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1

		db 1, 0, 0, 0, 0 ; L
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 0, 0
		db 1, 1, 1, 1, 1

		db 1, 0, 0, 0, 1 ; M
		db 1, 1, 0, 1, 1
		db 1, 0, 1, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1

		db 1, 0, 0, 0, 1 ; N
		db 1, 0, 0, 0, 1
		db 1, 1, 0, 0, 1
		db 1, 0, 1, 0, 1
		db 1, 0, 0, 1, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1

		db 0, 1, 1, 1, 0 ; O
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 0, 1, 1, 1, 0

		db 1, 1, 1, 1, 0 ; P
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 1, 1, 1, 0
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 0, 0

		db 0, 1, 1, 1, 0 ; Q
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 1, 0, 1
		db 1, 0, 0, 1, 0
		db 0, 1, 1, 0, 1

		db 1, 1, 1, 1, 0 ; R
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 1, 1, 1, 0
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1

		db 0, 1, 1, 1, 1 ; S
		db 1, 0, 0, 0, 0
		db 1, 0, 0, 0, 0
		db 0, 1, 1, 1, 0
		db 0, 0, 0, 0, 1
		db 0, 0, 0, 0, 1
		db 1, 1, 1, 1, 0

		db 1, 1, 1, 1, 1 ; T
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0

		db 1, 0, 0, 0, 1 ; U
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 0, 1, 1, 1, 0

		db 1, 0, 0, 0, 1 ; V
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 0, 1, 0, 1, 0
		db 0, 0, 1, 0, 0

		db 1, 0, 0, 0, 1 ; W
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1
		db 1, 0, 1, 0, 1
		db 1, 1, 0, 1, 1
		db 1, 0, 0, 0, 1

		db 1, 0, 0, 0, 1 ; X
		db 1, 0, 0, 0, 1
		db 0, 1, 0, 1, 0
		db 0, 0, 1, 0, 0
		db 0, 1, 0, 1, 0
		db 1, 0, 0, 0, 1
		db 1, 0, 0, 0, 1

		db 1, 0, 0, 0, 1 ; Y
		db 1, 0, 0, 0, 1
		db 0, 1, 0, 1, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0

		db 1, 1, 1, 1, 1 ; Z
		db 0, 0, 0, 0, 1
		db 0, 0, 0, 1, 0
		db 0, 0, 1, 0, 0
		db 0, 1, 0, 0, 0
		db 1, 0, 0, 0, 0
		db 1, 1, 1, 1, 1

		db 0, 0, 1, 1, 0 ; [
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 1, 0

		db 0, 0, 0, 0, 0 ; \
		
		db 1, 0, 0, 0, 0
		db 0, 1, 0, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 0, 1, 0
		db 0, 0, 0, 0, 1
		db 0, 0, 0, 0, 0

		db 0, 1, 1, 0, 0 ; ]
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 0, 1, 0, 0
		db 0, 1, 1, 0, 0

		db 0, 0, 1, 0, 0 ; ^
		db 0, 1, 0, 1, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0

		db 0, 0, 0, 0, 0 ; _
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0
		db 0, 1, 1, 1, 0
	
; ==============================================================================
;  Setting Cars Initial Positions their Spawn time collision variables and texts
; ==============================================================================

	; Player car Initial position For That Yellow Car and Truck
    PlayerX dw 160          
    PlayerY dw 160          
    PlayerLane db 1   ; Current lane (0=left, 1=center, 2=right)
    TargetX dw 160

	; Red sprite car lane control
	CarLane db 1            ; Current lane for red car (0=left, 1=center, 2=right)
	CarTargetX dw 128       ; Target X for red sprite car (car_x)
	CAR_CHANGE_SPEED equ 6  ; Same speed as player
	
	; Spawn constants
	EnemySpawnTimer dw 30     ; Spawn every 30 frames (~0.5 sec at 60fps)
	MaxEnemies equ 1          ; Start with 1 enemy;
	MAX_ENEMIES equ 5         ; Support up to 5 enemies on screen
	ENEMY_SPAWN_MIN equ 20    ; Min frames between spawns
	ENEMY_SPAWN_MAX equ 60    ; Max frames between spawns
    COIN_SPAWN_MIN equ 40     ; Minimum frames between coin spawns
    COIN_SPAWN_MAX equ 100    ; Maximum frames between coin spawns
    BARREL_SPAWN_MIN equ 80   ; Minimum frames between barrel spawns
    BARREL_SPAWN_MAX equ 160  ; Maximum frames between barrel spawns
    CoinSpawnTimer dw 60      ; Initial spawn delay
    BarrelSpawnTimer dw 120   ; Initial spawn delay
	
	; Enemy types
    ENEMY_RED_CAR equ 0
    ENEMY_YELLOW_CAR equ 1  
    ENEMY_TRUCK equ 2
    
    ; Current enemy type
    CurrentEnemyType db ENEMY_RED_CAR


	CollisionDetected db 0
    Lives db 1
    CollisionCooldown dw 0
	
	 ; Buffer flag
    number_buffer db 12 dup (0)
    
	;Game Score
    Score dw 0
	
; =============================================================
; 			         Difficulty Selection
; =============================================================
    DifficultyLevel db 1        ; 0=Easy, 1=Medium, 2=Hard
    SelectedOption db 1         ; Currently selected menu option
    
    ; Difficulty screen text
    diff_title dw (40) * 320 + (160 - 17 * 3)
               db 14, 0, 0, "SELECT DIFFICULTY", 0
    
    diff_option1 dw (80) * 320 + (160 - 8 * 3)
                 db 10, 0, 0, "1. EASY", 0
    
    diff_option2 dw (100) * 320 + (160 - 9 * 3)
                 db 14, 0, 0, "2. MEDIUM", 0
    
    diff_option3 dw (120) * 320 + (160 - 8 * 3)
                 db 12, 0, 0, "3. HARD", 0
    
    diff_desc1 dw (88) * 320 + (160 - 32 * 3)
               db 2, 0, 0, "LIVES: 3 \ SLOW SPEED \ FEW ENEMIES", 0
    
    diff_desc2 dw (108) * 320 + (160 - 35 * 3)
               db 6, 0, 0, "LIVES: 2 \ NORMAL SPEED \ NORMAL ENEMIES", 0
    
    diff_desc3 dw (128) * 320 + (160 - 32 * 3)
               db 4, 0, 0, "LIVES: 1 \ FAST SPEED \ MANY ENEMIES", 0
    
    diff_instruction dw (160) * 320 + (160 - 28 * 3)
                     db 15, 0, 0, "ARROW KEYS OR 1-3, PRESS ENTER", 0
			
	; Car names (for display)
	car1_name dw (140) * 320 + (162 - 30)
			  db 15, 0, 0, "SPEEDSTER", 0
	car2_name dw (140) * 320 + (170 - 30)
			  db 15, 0, 0, "THUNDER", 0
	car3_name dw (140) * 320 + (175 - 30)
			  db 15, 0, 0, "VIPER", 0
	car4_name dw (140) * 320 + (175 - 30)
			  db 15, 0, 0, "RACER", 0		  
	car5_name dw (140) * 320 + (175 - 30)
			  db 15, 0, 0, "TRUCK", 0
	car6_name dw (140) * 320 + (170 - 30)
			  db 15, 0, 0, "PHOENIX", 0		  
    
    ; Selector arrow
    selector_arrow db '>', 0

; ===========================================================
;                      Car Selection
; ===========================================================
	SelectedCar db 0            ; 0-6 for seven cars
    CurrentCarIndex db 0        ; For scrolling through cars
    
    ; Car filenames (64x64 sprites)
    car1_filename db 'CAR.raw', 0
    car2_filename db 'EnemyC1.raw', 0
    car3_filename db 'EnemyC2.raw', 0
    car4_filename db 'EnemyC3.raw', 0
    car5_filename db 'CAR2.raw', 0
    car6_filename db 'CAR3.raw', 0
    
    ; Car stats (Speed rating 1-5)
    car1_speed db 5
    car2_speed db 4
    car3_speed db 3
    car4_speed db 2
    car5_speed db 1
    car6_speed db 3
    
    ; Car stats (Handling rating 1-5)
    car1_handling db 5
    car2_handling db 3
    car3_handling db 2
    car4_handling db 1
    car5_handling db 1
    car6_handling db 3

    ; Car selection screen text
    car_title dw 35 * 320 + (185 - 25 * 3)
              db 14, 0, 0, "SELECT YOUR CAR", 0
    
    car_instruction dw 175 * 320 + (160 - 35 * 3)
                    db 15, 0, 0, "< LEFT \ RIGHT > \ ENTER TO SELECT", 0
    
    speed_label dw 155 * 320 + 40
                db 15, 0, 0, "SPEED:", 0
    
    handling_label dw 165 * 320 + 40
                   db 15, 0, 0, "HANDLING:", 0
				   
; ESC and exit handling
    old_keyboard_isr dd 0           ; Store original INT 9 handler
    esc_pressed db 0                ; Flag for ESC key press
    game_paused db 0                ; Flag for game pause state
    
    ; Exit confirmation messages
    exit_title dw 80 * 320 + (165 - 20 * 3)
               db 14, 0, 0, "EXIT CONFIRMATION", 0
    
    exit_msg1 dw 95 * 320 + (151 - 25 * 3)
              db 15, 0, 0, "ARE YOU SURE YOU WANT TO EXIT?", 0
    
    exit_msg2 dw 110 * 320 + (160 - 15 * 3)
              db 10, 0, 0, "PRESS Y FOR YES", 0
    
    exit_msg3 dw 120 * 320 + (160 - 14 * 3)
              db 12, 0, 0, "PRESS N FOR NO", 0
    
    final_score_msg dw 140 * 320 + (160 - 18 * 3)
                    db 14, 0, 0, "YOUR FINAL SCORE:     ", 0
	exit_farewell_msg db 0Dh, 0Ah, 'Thanks for playing!', 0Dh, 0Ah, '$'
; ===========================================================
; 					 Sprites Buffer 
; ===========================================================
	section .bss
	pal_buffer resb 768         ; 256 colors * 3 bytes (RGB)
	buffer resb 8192

	 ; Sprite buffers     
    tree1_buffer resb 1024
	tree2_buffer resb 4096
	car1_buffer  resb 4096 
	car2_buffer  resb 4096
	car3_buffer  resb 4096 
	car4_buffer  resb 4096 
	car5_buffer  resb 4096 
	car6_buffer  resb 4096 
    
    ; Sprite positions
    car_x   resw 1
    car_y   resw 1
	tree1_x resw 1
	tree1_y resw 1
	tree2_x resw 1
	tree2_y resw 1
    enemy1_x resw 1
    enemy1_y resw 1
    enemy1_active resb 1
    coin_x resw 1
    coin_y resw 1
    coin_active resb 1
    barrel_x resw 1
    barrel_y resw 1
    barrel_active resb 1	
	
	temp_collision resw 1
	
    file_handle resw 1
    temp_x resw 1
    temp_y resw 1
	

section .text
; ============================================
; SHOW INTRO SCREEN
; ============================================
ShowIntroScreen:
    ; Set video mode 13h (320x200, 256 colors)
    mov ax, 0x0013
    int 0x10

    ; Load palette (reuse existing procedure)
    call load_palette

    ; Open intro image
    mov ax, 0x3D00
    mov dx, intro_image
    int 0x21
    jc file_error
    mov [file_handle], ax

    ; Read file into video memory
    mov bx, [file_handle]
    mov ax, 0xA000
    mov es, ax
    xor di, di

.read_loop_intro:
    mov ah, 0x3F
    mov cx, 8192
    mov dx, buffer
    int 0x21
    jc file_error
    cmp ax, 0
    je .done
    mov cx, ax
    mov si, buffer
    rep movsb
    jmp .read_loop_intro

.done:
    ; Close file
    mov ah, 0x3E
    mov bx, [file_handle]
    int 0x21

    ; Wait for keypress
	xor ah, ah
	int 0x16
	
	mov ax, 0x0013
	int 0x10
	
	ret
	
start:
	call Loading_Screen
	call load_palette
restart:
	call LoadAllCars
	call FlushKeyboardBuffer
	call ShowDifficultyScreen
	call clrscr
	call ShowCarSelectionScreen
	call clrscr
	call ShowIntroScreen
	call clrscr
    call InitVideo
	call load_palette
	call LoadAllSprites
	call InitializeSprites
	call InitBuffer 

	MainLoop:
	
    ; Handle input
    call HandleInput
	 
	; Update positions
	call UpdatePlayerPosition
	
	; CHECK FOR COLLISIONS
    call CheckCollisions
	
	; Scroll enemies
	call UpdateEnemies   	
	
	; Update red sprite car position (lane change)
    call UpdateCarPosition
	
	call UpdateScrolling
	
	; Draw everything to buffer
    call DrawToBuffer
	
	; Wait for vertical sync
    call WaitVSync
	
	; Copy buffer to screen during vsync
    call CopyBufferToScreen
	
	

	; Small delay
    ; call GameDelay
    
    jmp MainLoop

; Show File error msg if File not opened
error_msg db 'File error!$'
file_error:
    mov ax, 0x0003
    int 0x10
    
    mov ah, 0x09
    mov dx, error_msg
    int 0x21
    
    mov ax, 0x4C01
    int 0x21

; =============== Sprite Loader ===================
; LoadSprite:
;   DX = pointer to filename
;   DI = pointer to buffer
;   CX = sprite size in bytes (width*height)
; =================================================
LoadSprite:
    push ax
    push bx
    push cx
    push dx

    mov ax, 0x3D00          ; open file (read-only)
    int 0x21
    jc file_error

    mov [file_handle], ax

    mov ah, 0x3F             ; read file
    mov bx, [file_handle]
    mov dx, di               ; DX = buffer pointer
    int 0x21
    jc file_error

    mov ah, 0x3E             ; close file
    mov bx, [file_handle]
    int 0x21

.error:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
	
;================Set Sprites Initial Starting Positions================
InitializeSprites:
	;Red CAR
    mov word [car_x], 128
    mov word [car_y], 138
	mov byte [CarLane], 1       ; Start in center lane
    mov word [CarTargetX], 128  ; Target is center
    
    ; --- Tree 1 (LEFT SIDE) ---
    mov word [tree1_x], 25     
    mov word [tree1_y], 20
    
    ; --- Tree 2 (RIGHT SIDE) ---
    mov word [tree2_x], 255     
    mov word [tree2_y], 80
   
    mov byte [coin_active], 0
    
	mov byte [barrel_active], 0
    
    ret
	
; ================= Sprite Drawer ===================
; DrawSprite:
;   AX = X position
;   BX = Y position
;   SI = pointer to sprite buffer
;   CX = sprite width
;   DX = sprite height
; ===================================================
DrawSprite:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    push bp

    mov [temp_x], ax
    mov [temp_y], bx
    mov bp, cx              ; save width

.row_loop:
    push cx
    push dx

    mov ax, [temp_y]
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, [temp_x]
    mov di, ax

    mov cx, bp

.pixel_loop:
    lodsb                   ; load pixel
    
    ; Check for transparent color (0 = black = transparent)
    test al, al             ; Check if AL is 0
    jz .skip_pixel          ; If zero, skip this pixel
    
    ; Draw non-transparent pixel
    mov [es:di], al
    
.skip_pixel:
    inc di
    loop .pixel_loop

    inc word [temp_y]
    pop dx
    pop cx
    dec dx
    jnz .row_loop

    pop bp
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
	
; ===============================================
;   			Load All Sprites
; ===============================================
LoadAllSprites:
    push ax
    push bx
    push cx
    push dx
    push di
	
	; --- Tree 1 ---
	mov dx, tree1_filename
	mov di, tree1_buffer
	mov cx, 1024
	call LoadSprite
	
	; --- Tree 2 ---
	mov dx, tree2_filename
	mov di, tree2_buffer
	mov cx, 4096
	call LoadSprite 
 
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
	
; ============================================
; LOAD PALETTE FROM .PAL FILE
; ============================================
load_palette:
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; Open palette file
    mov ax, 0x3D00
    mov dx, pal_filename
    int 0x21
    jc .error
    
    mov bx, ax              ; Save file handle
    
    ; Read palette data (768 bytes = 256 colors * 3 bytes RGB)
    mov ah, 0x3F
    mov cx, 768
    mov dx, pal_buffer
    int 0x21
    
    ; Close palette file
    push ax                 ; Save bytes read
    mov ah, 0x3E
    int 0x21
    pop ax                  ; Restore bytes read
    
    cmp ax, 768             ; Check if we read 768 bytes
    jl .error
    
    ; Set VGA palette
    mov si, pal_buffer
    xor cx, cx              ; Start with color 0
    
.set_color:
    mov dx, 0x03C8          ; DAC write index
    mov al, cl
    out dx, al
    
    mov dx, 0x03C9          ; DAC data port
    
    ; Read RGB from buffer and divide by 4 (VGA uses 6-bit color 0-63)
    lodsb                   ; Load R
    shr al, 2               ; Divide by 4
    out dx, al
    
    lodsb                   ; Load G
    shr al, 2
    out dx, al
    
    lodsb                   ; Load B
    shr al, 2
    out dx, al
    
    inc cx
    cmp cx, 256
    jl .set_color
    
.error:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
	
; ============================================
; BACKGROUND DRAWING
; ============================================
DrawLandscape:
    ; Draw grass on both sides
    push ax
    push bx
    push cx
    push dx
    push di
    
    ; Left grass area
    mov bx, 0
.left_loop:
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    mov di, ax
    
    mov cx, ROAD_LEFT
    mov al, COLOR_GRASS
    rep stosb
    
    inc bx
    cmp bx, SCREEN_HEIGHT
    jl .left_loop
    
    ; Right grass area
    mov bx, 0
.right_loop:
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, ROAD_RIGHT
    mov di, ax
    
    mov cx, 80              ; Right side width (fills to edge)
    mov al, COLOR_GRASS
    rep stosb
    
    inc bx
    cmp bx, SCREEN_HEIGHT
    jl .right_loop
    
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; DRAW MULTIPLE STONES ON LANDSCAPE
; ============================================
DrawStones:
    push ax
    push bx
    
    ; Left side stones
    ; Large stone
    mov ax, 40
    mov bx, 40
    call DrawLargeStone
	
	mov ax, 50
	mov bx, 40
	call DrawStone
    
    ; Small stones
    mov ax, 50
    mov bx, 80
    call DrawStone
    
	mov ax, 25
    mov bx, 175
    call DrawStone
    
	mov ax, 18
    mov bx, 175
    call DrawLargeStone
    
    ; Right side stones
    ; Large stones
    mov ax, 280
    mov bx, 35
    call DrawLargeStone
    
    ; Small stones
    mov ax, 265
    mov bx, 75
    call DrawStone
    
    mov ax, 285
    mov bx, 105
    call DrawStone
    
	mov ax, 290
    mov bx, 105
    call DrawLargeStone
	
    mov ax, 270
    mov bx, 145
    call DrawStone
    
    
    pop bx
    pop ax
    ret
; ============================================
; DRAW SINGLE STONE/ROCK
; Input: AX = X position, BX = Y position
; ============================================
DrawStone:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
	
    cmp ax, ROAD_LEFT - 8       ; allow drawing up to 8 pixels before road
	jl .safe_to_draw
	cmp ax, ROAD_RIGHT - 8      ; move boundary left by stone width
	jle .skip_draw
	
	.safe_to_draw:
    mov si, ax          ; Save X position
    
    ; Draw stone as circles (6x6 pixels)
    
    ; Row 1: Top (2 pixels - dark)
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, si
    add ax, 2           ; Center
    mov di, ax
    mov byte [es:di], 8     ; Dark gray
    inc di
    mov byte [es:di], 8
    
    ; Row 2: (4 pixels - mid with light)
    inc bx
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, si
    add ax, 1
    mov di, ax
    mov byte [es:di], 8     ; Dark
    inc di
    mov byte [es:di], 15    ; Light highlight
    inc di
    mov byte [es:di], 7     ; Mid
    inc di
    mov byte [es:di], 8     ; Dark
    
    ; Row 3: (5 pixels - full width)
    inc bx
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, si
    mov di, ax
    mov byte [es:di], 8     ; Dark edge
    inc di
    mov byte [es:di], 7     ; Mid
    inc di
    mov byte [es:di], 7     ; Mid
    inc di
    mov byte [es:di], 7     ; Mid
    inc di
    mov byte [es:di], 8     ; Dark edge
    
    ; Row 4: (5 pixels - middle)
    inc bx
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, si
    mov di, ax
    mov byte [es:di], 8     ; Dark edge
    inc di
    mov byte [es:di], 7     ; Mid
    inc di
    mov byte [es:di], 7     ; Mid
    inc di
    mov byte [es:di], 7     ; Mid
    inc di
    mov byte [es:di], 8     ; Dark edge
    
    ; Row 5: (4 pixels - bottom narrowing)
    inc bx
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, si
    add ax, 1
    mov di, ax
    mov byte [es:di], 8     ; Dark
    inc di
    mov byte [es:di], 7     ; Mid
    inc di
    mov byte [es:di], 7     ; Mid
    inc di
    mov byte [es:di], 8     ; Dark
    
    ; Row 6: Bottom (2 pixels - dark)
    inc bx
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, si
    add ax, 2
    mov di, ax
    mov byte [es:di], 8     ; Dark
    inc di
    mov byte [es:di], 8     ; Dark
	
    .skip_draw:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; DRAW LARGER STONE (like the left one in image)
; Input: AX = X position, BX = Y position
; ============================================
DrawLargeStone:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
	cmp ax, ROAD_LEFT - 5
	jl .safe_to_draw
	cmp ax, ROAD_RIGHT - 5
	jle .skip_draw
	
	.safe_to_draw:
    mov si, ax          ; Save X position
    
    ; Larger stone (8x8 pixels)
    
    ; Row 1: Top (3 pixels)
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, si
    add ax, 2
    mov di, ax
    mov cx, 3
.row1:
    mov byte [es:di], 8     ; Dark gray
    inc di
    loop .row1
    
    ; Row 2: (5 pixels with highlight)
    inc bx
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, si
    add ax, 1
    mov di, ax
    mov byte [es:di], 8     ; Dark
    inc di
    mov byte [es:di], 15    ; White highlight
    inc di
    mov byte [es:di], 7     ; Light gray
    inc di
    mov byte [es:di], 7     ; Light gray
    inc di
    mov byte [es:di], 8     ; Dark
    
    ; Row 3: (7 pixels)
    inc bx
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, si
    mov di, ax
    mov byte [es:di], 8
    inc di
    mov byte [es:di], 7
    inc di
    mov byte [es:di], 7
    inc di
    mov byte [es:di], 7
    inc di
    mov byte [es:di], 7
    inc di
    mov byte [es:di], 7
    inc di
    mov byte [es:di], 8
    
    ; Row 4: (8 pixels - widest)
    inc bx
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, si
    mov di, ax
    mov cx, 8
.row4:
    push cx
    cmp cx, 8
    je .dark4
    cmp cx, 1
    je .dark4
    mov byte [es:di], 7     ; Mid gray
    jmp .next4
.dark4:
    mov byte [es:di], 8     ; Dark edges
.next4:
    inc di
    pop cx
    loop .row4
    
    ; Row 5: (8 pixels)
    inc bx
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, si
    mov di, ax
    mov cx, 8
.row5:
    push cx
    cmp cx, 8
    je .dark5
    cmp cx, 1
    je .dark5
    mov byte [es:di], 7
    jmp .next5
.dark5:
    mov byte [es:di], 8
.next5:
    inc di
    pop cx
    loop .row5
    
    ; Row 6: (7 pixels)
    inc bx
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, si
    mov di, ax
    mov cx, 7
.row6:
    push cx
    cmp cx, 7
    je .dark6
    cmp cx, 1
    je .dark6
    mov byte [es:di], 7
    jmp .next6
.dark6:
    mov byte [es:di], 8
.next6:
    inc di
    pop cx
    loop .row6
    
    ; Row 7: (5 pixels)
    inc bx
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, si
    add ax, 1
    mov di, ax
    mov cx, 5
.row7:
    mov byte [es:di], 8
    inc di
    loop .row7
    
    ; Row 8: Bottom (3 pixels)
    inc bx
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, si
    add ax, 2
    mov di, ax
    mov cx, 3
.row8:
    mov byte [es:di], 8
    inc di
    loop .row8
    
	.skip_draw:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DrawRoad:
    ; Draw the main road (3 lanes)
    push ax
    push bx
    push cx
    push dx
    push di
    
    mov bx, 0
.road_loop:
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, ROAD_LEFT
    mov di, ax
    
    mov cx, ROAD_WIDTH
    mov al, COLOR_ROAD
    rep stosb
    
    inc bx
    cmp bx, SCREEN_HEIGHT
    jl .road_loop
    
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ==================================================
;				   Road Markings
; ==================================================
DrawRoadMarkings:
    ; Draw lane dividers with scrolling animation
    push ax
    push bx
    push cx
    push dx
    push di
    
    ; Get scroll offset
    mov dx, [RoadLineOffset]
    
    ; Left lane divider (between lane 0 and 1)
    mov bx, 0
    sub bx, dx                  ; Start above screen with offset
.left_divider:
    cmp bx, 0
    jl .skip_left_dash
    
    ; Draw dash (10 pixels)
    mov cx, 10
.left_dash:
    cmp bx, SCREEN_HEIGHT
    jge .left_done
    
    mov ax, bx
    push dx
    mov dx, SCREEN_WIDTH
    mul dx
    pop dx
    add ax, ROAD_LEFT
    add ax, LANE_WIDTH
    mov di, ax
    
    mov byte [es:di], COLOR_LINES
    inc di
    mov byte [es:di], COLOR_LINES
    
    inc bx
    loop .left_dash
    
.skip_left_dash:
    ; Skip gap (10 pixels)
    add bx, 10
    
    cmp bx, SCREEN_HEIGHT
    jl .left_divider
    
.left_done:
    ; Right lane divider (between lane 1 and 2)
    mov dx, [RoadLineOffset]
    mov bx, 0
    sub bx, dx
.right_divider:
    cmp bx, 0
    jl .skip_right_dash
    
    ; Draw dash
    mov cx, 10
.right_dash:
    cmp bx, SCREEN_HEIGHT
    jge .right_done
    
    mov ax, bx
    push dx
    mov dx, SCREEN_WIDTH
    mul dx
    pop dx
    add ax, ROAD_LEFT
    push dx
    mov dx, LANE_WIDTH
    add dx, LANE_WIDTH
    add ax, dx
    pop dx
    mov di, ax
    
    mov byte [es:di], COLOR_LINES
    inc di
    mov byte [es:di], COLOR_LINES
    
    inc bx
    loop .right_dash
    
.skip_right_dash:
    ; Skip gap
    add bx, 10
    
    cmp bx, SCREEN_HEIGHT
    jl .right_divider
    
.right_done:
    ; Draw road edges (solid lines - these don't scroll)
    mov bx, 0
.edges:
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    
    ; Left edge
    mov di, ax
    add di, ROAD_LEFT
    mov byte [es:di], COLOR_ROAD_EDGES
    inc di
    mov byte [es:di], COLOR_ROAD_EDGES
    inc di
    mov byte [es:di], COLOR_ROAD_EDGES
    
    ; Right edge
    mov di, ax
    add di, ROAD_RIGHT
    mov byte [es:di], COLOR_ROAD_EDGES
    dec di
    mov byte [es:di], COLOR_ROAD_EDGES
    inc di
    mov byte [es:di], COLOR_ROAD_EDGES
    inc di
    mov byte [es:di], COLOR_ROAD_EDGES
    
    inc bx
    cmp bx, SCREEN_HEIGHT
    jl .edges
    
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ===================================================
; 				   Trees Drawings
; ===================================================
DrawTrees:
    ; Draw decorative trees on landscape
    push ax
    push bx
	push cx
	 ; === LEFT SIDE TREES ===
    ;Tree 1: Top left corner
    mov ax, 25
    mov bx, 15
    call DrawBushyTree
    
    ;Tree 2: Left side, lower
    mov ax, 60
    mov bx, 60
    call DrawSingleTree
    
    ; Tree 3: Left side, middle
    mov ax, 25
    mov bx, 105
    call DrawBushyTree
    
    ; Tree 4: Left side, lower-middle
    mov ax, 60
    mov bx, 160
    call DrawSingleTree
    
	
	;=== RIGHT SIDE TREES ===
    ; Tree 5: Top right
    mov ax, 260
    mov bx, 20
    call DrawSingleTree
    
    ; Tree 6: Right side, upper
    mov ax, 290
    mov bx, 70
    call DrawBushyTree
    
    ; Tree 7: Right side, middle
    mov ax, 260
    mov bx, 115
    call DrawSingleTree
    
    ; Tree 8: Right side, bottom
    mov ax, 290
    mov bx, 160
    call DrawBushyTree
    
    pop cx
    pop bx
    pop ax
    ret
DrawBushyTree:
    ; AX = X position, BX = Y position
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    mov si, ax
    
    ; Draw taller trunk (5 pixels wide, 12 tall) - INCREASED
    mov dx, 12          ; 12 pixels
.trunk:
    mov ax, bx
    push dx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    mov di, ax
    pop dx
    
    mov byte [es:di], COLOR_TRUNK
    inc di
    mov byte [es:di], COLOR_TRUNK
    inc di
    mov byte [es:di], COLOR_TRUNK
    inc di
    mov byte [es:di], COLOR_TRUNK
    inc di
    mov byte [es:di], COLOR_TRUNK    ; 5 pixels wide now
    
    inc bx
    dec dx
    jnz .trunk
    
    ; Draw bigger round bushy top
    sub bx, 12          ; Match new trunk height
    sub bx, 10          ; Above trunk Pixels
    
    ; Row 1: (7 pixels)
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    sub ax, 1
    mov di, ax
    mov cx, 7
.row1:
    mov byte [es:di], COLOR_TREE
    inc di
    loop .row1
    
    ; Row 2: (11 pixels) 
    inc bx
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    sub ax, 3
    mov di, ax
    mov cx, 11
.row2:
    mov byte [es:di], COLOR_TREE
    inc di
    loop .row2
    
    ; Row 3: (15 pixels) 
    inc bx
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    sub ax, 5
    mov di, ax
    mov cx, 15
.row3:
    mov byte [es:di], COLOR_TREE
    inc di
    loop .row3
    
    ; Row 4: (17 pixels) - widest
    inc bx
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    sub ax, 6
    mov di, ax
    mov cx, 17
.row4:
    mov byte [es:di], COLOR_TREE
    inc di
    loop .row4
    
    ; Row 5: (19 pixels) - WIDER
    inc bx
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    sub ax, 7
    mov di, ax
    mov cx, 19
.row5:
    mov byte [es:di], COLOR_TREE
    inc di
    loop .row5
    
    ; Row 6: (19 pixels)
    inc bx
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    sub ax, 7
    mov di, ax
    mov cx, 19
.row6:
    mov byte [es:di], COLOR_TREE
    inc di
    loop .row6
    
    ; Row 7: (17 pixels)
    inc bx
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    sub ax, 6
    mov di, ax
    mov cx, 17
.row7:
    mov byte [es:di], COLOR_TREE
    inc di
    loop .row7
    
    ; Row 8: (15 pixels)
    inc bx
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    sub ax, 5
    mov di, ax
    mov cx, 15
.row8:
    mov byte [es:di], COLOR_TREE
    inc di
    loop .row8
    
    ; Row 9: (11 pixels)
    inc bx
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    sub ax, 3
    mov di, ax
    mov cx, 11
.row9:
    mov byte [es:di], COLOR_TREE
    inc di
    loop .row9
    
    ; Row 10: (7 pixels) - bottom
    inc bx
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    sub ax, 1
    mov di, ax
    mov cx, 7
.row10:
    mov byte [es:di], COLOR_TREE
    inc di
    loop .row10
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DrawSingleTree:
    ; AX = X position, BX = Y position
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov si, ax          ; Save X position in SI permanently

    ; Draw trunk (4 pixels wide, 10 tall)
    mov dx, 10           ; Trunk height 10 px tall
.trunk:
    ; Calculate position: BX * 320 + SI
    mov ax, bx
    push dx
    mov dx, SCREEN_WIDTH
    mul dx              ; AX = BX * 320
    add ax, si          ; Add X position
    mov di, ax
    pop dx

    ; Draw 4 pixels of trunk
    mov byte [es:di], COLOR_TRUNK
    inc di
    mov byte [es:di], COLOR_TRUNK
    inc di
    mov byte [es:di], COLOR_TRUNK
    inc di
    mov byte [es:di], COLOR_TRUNK

    inc bx              ; Next row
    dec dx
    jnz .trunk

    ; Draw leaves (triangle shape)
    sub bx, 8          ; Back to top of trunk 
    sub bx, 6           ; Above trunk for leave
    ;Tree Top 1st row(3 Pixels)
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    sub ax, 0      ; Center
    mov di, ax
    mov cx, 3        ;3 Pixel wide
.DrawLeaveLevel_1:
    mov byte [es:di], COLOR_TREE
    inc di
    loop .DrawLeaveLevel_1

    ;2nd Row (7 Pixels)
    inc bx
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    sub ax, 2           ; start 2 pixel left
    mov di, ax
    mov cx, 7            ;7 pixel wide
.DrawLeaveLevel_2:
    mov byte [es:di], COLOR_TREE
    inc di
    loop .DrawLeaveLevel_2

    ; 3rd row (11 pixels)
    inc bx
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    sub ax, 4           ; Start 4 pixel left
    mov di, ax
    mov cx, 11            ;11 pixel wide
.DrawLeaveLevel_3:
    mov byte [es:di], COLOR_TREE
    inc di
    loop .DrawLeaveLevel_3

    ; 4th row (17 pixels)
    inc bx
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    sub ax, 7             ;start 6 pixel left
    mov di, ax
    mov cx, 17            ;17 pixel wide
.DrawLeaveLevel_4:
    mov byte [es:di], COLOR_TREE
    inc di
    loop .DrawLeaveLevel_4

    ; 5th row (21 pixels)
    inc bx
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    sub ax, 9           ; Start 9 pixel left
    mov di, ax
    mov cx, 21            ;21 Pixel wide at left (bottom)
.DrawLeaveLevel_5:
    mov byte [es:di], COLOR_TREE
    inc di
    loop .DrawLeaveLevel_5

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
	
; ============================================
; PLAYER CAR DRAWING
; ============================================
; --------------------------------------------
; Car 1 Yellow
; --------------------------------------------
DrawPlayerCar:
    ; Draw a top-down racing car (like the image)
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    mov bx, [temp_y]
    mov si, [temp_x]
    
    ; Car is 24 pixels wide, 30 pixels tall
    sub si, 12          ; Center the car
    
    ; ===== ROW 1-2: Front bumper (rounded) =====
    push bx
    mov dx, 2
.front_bumper:
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 8           ; Start 8 pixels in
    mov di, ax
    
    pop dx
    
    mov cx, 8           ; 8 pixels wide (rounded front)
    mov al, 14          ; Yellow
    rep stosb
    
    pop si
    inc bx
    dec dx
    jnz .front_bumper
    pop bx
    
    ; ===== ROW 3-4: Front with headlights =====
    push bx
    add bx, 2
    mov dx, 2
.front_lights:
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 6
    mov di, ax
    
    pop dx
    
    ; Left headlight area
    mov byte [es:di], 14    ; Yellow
    inc di
    mov byte [es:di], 14
    inc di
    
    ; Yellow body
    mov cx, 8
    mov al, 14
    rep stosb
    
    ; Right headlight area
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    
    pop si
    inc bx
    dec dx
    jnz .front_lights
    pop bx
    
    ; ===== ROW 5-8: Hood with red stripe =====
    push bx
    add bx, 4
    mov dx, 4
.hood:
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 4
    mov di, ax
    
    pop dx
    
    ; Draw hood: Yellow-Red-Red-Yellow pattern
    mov cx, 16
    push cx
    
    ; Left yellow (5 pixels)
    mov cx, 5
.hood_left:
    mov byte [es:di], 14    ; Yellow
    inc di
    loop .hood_left
    
    ; Red stripes (6 pixels)
    mov cx, 6
.hood_stripe:
    mov byte [es:di], 12    ; Red
    inc di
    loop .hood_stripe
    
    ; Right yellow (5 pixels)
    mov cx, 5
.hood_right:
    mov byte [es:di], 14    ; Yellow
    inc di
    loop .hood_right
    
    pop cx
    pop si
    inc bx
    dec dx
    jnz .hood
    pop bx
    
    ; ===== ROW 9-10: Front windshield =====
    push bx
    add bx, 8
    mov dx, 2
.front_window:
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 4
    mov di, ax
    
    pop dx
    
    ; Left yellow border
    mov cx, 4
    mov al, 14
    rep stosb
    
    ; Light blue window
    mov cx, 8
    mov al, 11          ; Light cyan/blue
    rep stosb
    
    ; Right yellow border
    mov cx, 4
    mov al, 14
    rep stosb
    
    pop si
    inc bx
    dec dx
    jnz .front_window
    pop bx
    
    ; ===== ROW 11-14: Main body with red stripes =====
    push bx
    add bx, 10
    mov dx, 4
.main_body:
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 2
    mov di, ax
    
    pop dx
    
    ; Left yellow (7 pixels)
    mov cx, 7
.body_left:
    mov byte [es:di], 14
    inc di
    loop .body_left
    
    ; Red stripes (6 pixels)
    mov cx, 6
.body_stripe:
    mov byte [es:di], 12
    inc di
    loop .body_stripe
    
    ; Right yellow (7 pixels)
    mov cx, 7
.body_right:
    mov byte [es:di], 14
    inc di
    loop .body_right
    
    pop si
    inc bx
    dec dx
    jnz .main_body
    pop bx
    
    ; ===== ROW 15-16: Side mirrors/windows =====
    push bx
    add bx, 14
    mov dx, 2
.side_windows:
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    mov di, ax
    add di,2
    pop dx
    
    ; Full width with windows
    mov byte [es:di], 14    ; Yellow
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 11    ; Blue window left
    inc di
    mov byte [es:di], 11
    inc di
    
    mov cx, 12
    mov al, 14              ; Yellow body
    rep stosb
    
    mov byte [es:di], 11    ; Blue window right
    inc di
    mov byte [es:di], 11
    inc di
    mov byte [es:di], 14    ; Yellow
    inc di
    mov byte [es:di], 14
    
    pop si
    inc bx
    dec dx
    jnz .side_windows
    pop bx
    
    ; ===== ROW 17-18: Rear windshield =====
    push bx
    add bx, 16
    mov dx, 2
.rear_window:
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 4
    mov di, ax
    
    pop dx
    
    ; Yellow border
    mov cx, 4
    mov al, 14
    rep stosb
    
    ; Blue window
    mov cx, 8
    mov al, 11
    rep stosb
    
    ; Yellow border
    mov cx, 4
    mov al, 14
    rep stosb
    
    pop si
    inc bx
    dec dx
    jnz .rear_window
    pop bx
    
    ; ===== ROW 19-24: Rear with red stripes =====
    push bx
    add bx, 18
    mov dx, 6
.rear_body:
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 4
    mov di, ax
    
    pop dx
    
    ; Yellow left
    mov cx, 5
.rear_left:
    mov byte [es:di], 14
    inc di
    loop .rear_left
    
    ; Red stripe
    mov cx, 6
.rear_stripe:
    mov byte [es:di], 12
    inc di
    loop .rear_stripe
    
    ; Yellow right
    mov cx, 5
.rear_right:
    mov byte [es:di], 14
    inc di
    loop .rear_right
    
    pop si
    inc bx
    dec dx
    jnz .rear_body
    pop bx
    
    ; ===== ROW 25-26: Rear with tail lights =====
    push bx
    add bx, 24
    mov dx, 2
.rear_lights:
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 6
    mov di, ax
    
    pop dx
    
    ; Left tail light
    mov byte [es:di], 12    ; Red
    inc di
    mov byte [es:di], 12
    inc di
    
    ; Yellow body
    mov cx, 8
    mov al, 14
    rep stosb
    
    ; Right tail light
    mov byte [es:di], 12    ; Red
    inc di
    mov byte [es:di], 12
    
    pop si
    inc bx
    dec dx
    jnz .rear_lights
    pop bx
    
    ; ===== ROW 27-28: Rear bumper (rounded) =====
    push bx
    add bx, 26
    mov dx, 2
.rear_bumper:
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 8
    mov di, ax
    
    pop dx
    
    mov cx, 8           ; Rounded rear
    mov al, 14
    rep stosb
    
    pop si
    inc bx
    dec dx
    jnz .rear_bumper
    pop bx
    
    ; ===== WHEELS (Black with gray centers) =====
    ; Front left wheel
    push bx
    add bx, 6
    mov dx, 4
.fl_wheel:
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    mov di, ax
    
    pop dx
    
    mov byte [es:di], 0
    inc di
	mov byte [es:di], 0
    inc di
    mov byte [es:di], 8
    inc di
	mov byte [es:di], 0
    inc di
    
    pop si
    inc bx
    dec dx
    jnz .fl_wheel
    pop bx
    
    ; Front right wheel
    push bx
    add bx, 6
    mov dx, 4
.fr_wheel:
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 20
    mov di, ax
    
    pop dx
    
    mov byte [es:di], 0
    inc di
    mov byte [es:di], 8
    inc di
	mov byte [es:di], 0
    inc di
	mov byte [es:di], 0
    inc di
    
    pop si
    inc bx
    dec dx
    jnz .fr_wheel
    pop bx
    
    ; Rear left wheel
    push bx
    add bx, 20
    mov dx, 4
.rl_wheel:
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    mov di, ax
    
    pop dx
    
	mov byte [es:di], 0
    inc di
    mov byte [es:di], 0
    inc di
    mov byte [es:di], 8
    inc di
	mov byte [es:di], 0
    inc di
	
    
    pop si
    inc bx
    dec dx
    jnz .rl_wheel
    pop bx
    
    ; Rear right wheel
    push bx
    add bx, 20
    mov dx, 4
.rr_wheel:
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 20
    mov di, ax
    
    pop dx
    
    mov byte [es:di], 0
    inc di
    mov byte [es:di], 8
    inc di
    mov byte [es:di], 0
	inc di
	mov byte [es:di], 0
    inc di
    
    pop si
    inc bx
    dec dx
    jnz .rr_wheel
    pop bx
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
; =============================================
; 				Car 2 Truck 
; =============================================
DrawPlayerTruck:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    mov bx, [temp_y]
    mov si, [temp_x]
    
    ; Car body (main rectangle) - 24 wide, 30 tall
    sub si, 12          ; Center the car
    
    ; Draw car body
    push bx
    add bx, 10
    mov dx, 15
.body:
    push cx
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    mov di, ax
    
    pop dx
    
    mov cx, 24
    mov al, COLOR_CAR_BODY
    rep stosb
    
    pop si
    pop cx
    
    inc bx
    dec dx
    jnz .body
    pop bx
    
    ; Draw car roof (narrower)
    push bx
    add bx, 2
    mov dx, 8
.roof:
    push cx
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 6           ; Indent
    mov di, ax
    
    pop dx
    
    mov cx, 12
    mov al, COLOR_CAR_ROOF
    rep stosb
    
    pop si
    pop cx
    
    inc bx
    dec dx
    jnz .roof
    pop bx
    
    ; Draw windshield
    push bx
    add bx, 3
    mov dx, 4
.windshield:
    push cx
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 8
    mov di, ax
    
    pop dx
    
    mov cx, 8
    mov al, COLOR_WINDOW
    rep stosb
    
    pop si
    pop cx
    
    inc bx
    dec dx
    jnz .windshield
    pop bx
    
    ; Draw wheels (4 wheels)
    ; Front left wheel
    push bx
    add bx, 25
    mov dx, 5
.fl_wheel:
    push cx
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 2
    mov di, ax
    
    pop dx
    
    mov cx, 4
    mov al, COLOR_WHEEL
    rep stosb
    
    pop si
    pop cx
    
    inc bx
    dec dx
    jnz .fl_wheel
    pop bx
    
    ; Front right wheel
    push bx
    add bx, 25
    mov dx, 5
.fr_wheel:
    push cx
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 18
    mov di, ax
    
    pop dx
    
    mov cx, 4
    mov al, COLOR_WHEEL
    rep stosb
    
    pop si
    pop cx
    
    inc bx
    dec dx
    jnz .fr_wheel
    pop bx
    
    ; Rear left wheel
    push bx
    add bx, 12
    mov dx, 5
.rl_wheel:
    push cx
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 2
    mov di, ax
    
    pop dx
    
    mov cx, 4
    mov al, COLOR_WHEEL
    rep stosb
    
    pop si
    pop cx
    
    inc bx
    dec dx
    jnz .rl_wheel
    pop bx
    
    ; Rear right wheel
    push bx
    add bx, 12
    mov dx, 5
.rr_wheel:
    push cx
    push si
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 18
    mov di, ax
    
    pop dx
    
    mov cx, 4
    mov al, COLOR_WHEEL
    rep stosb
    
    pop si
    pop cx
    
    inc bx
    dec dx
    jnz .rr_wheel
    pop bx
    
    ; Draw headlights
    add bx, 26
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 4
    mov di, ax
    mov byte [es:di], 14    ; Yellow headlight
    inc di
    mov byte [es:di], 14
    
    add di, 12
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
	ret
; ============================================
; 			DRAW SCORE AREA
; ============================================
DrawScoreArea:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
	
	mov ax, BUFFER_SEG
    mov es, ax 
    
    ; Position score at top right (around X=250, Y=5)
    mov si, 250           ; X position
    mov bx, 5             ; Y position
    
    ; ===== Draw score background box =====
    ; Main background (dark blue)
    push bx
    mov dx, 20           ; Height of score box
.score_bg:
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    mov di, ax
    
    pop dx
    
    ; Draw background with gradient effect
    mov cx, 60            ; Width of score box
    mov al, 1             ; Dark blue background
    rep stosb
    
    inc bx
    dec dx
    jnz .score_bg
    pop bx
    
    ; ===== Draw border =====
    ; Top border (yellow)
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    mov di, ax
    
    mov cx, 60
    mov al, 14            ; Yellow border
    rep stosb
    
    ; Bottom border (yellow)
    add ax, SCREEN_WIDTH    ; Move to bottom row
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    add ax, SCREEN_WIDTH
    mov di, ax
	
	add di, 44
    
    mov cx, 60
    mov al, 14            ; Yellow border
    rep stosb
    
    ; Left and right borders
    mov dx, 18           ; Middle rows
.borders:
    push dx
    
    ; Left border
    mov ax, bx
    add ax, 1             ; Skip top border
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    mov di, ax
    mov byte [es:di], 14  ; Yellow
    
    ; Right border
    add di, 59           ; Move to right edge
    mov byte [es:di], 14  ; Yellow
    
    inc bx
    pop dx
    dec dx
    jnz .borders
    
    ; ===== Draw "SCORE:" text =====
    mov si, ScoreText
    call printStr

    ; ; ===== Draw the numeric score =====
    mov bx, [Score]       ; Get score
    call printNum
	
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

sleep:
	cmp dl, 0
	je .quit
	push cx
	push dx
.time:
	mov cx, 0xFFFF
	.delay:
		loop .delay
	dec dl
	jne .time
	pop dx
	pop cx
.quit:
	ret
	
printStr:
	push ax
	push bx
	push cx
	push dx
	push di
	
	mov di, [si]
	mov dx, [si + 4]
	xor dh, dh
	push dx
	mov dx, [si + 2]
	add si, 5
.oloop:
	xor ax, ax
	lodsb
	cmp ax, 0
	je .return
	sub ax, 32
	mov bx, 35
	push dx
	mul bx
	pop dx
	push si
	mov si, char5x7
	add si, ax
	mov bx, 7
.iloop:
	mov cx, 5
.pixel:
	lodsb
	cmp al, 0
	je .bg
	add al, dl
	dec al
	jmp .sto
.bg:
	add al, dh
.sto:
	stosb
	loop .pixel
	add di, 315
	dec bx
	cmp bx, 0
	jne .iloop
	sub di, 2234
	pop si
	mov ax, dx
	pop dx
	call sleep
	push dx
	mov dx, ax
	jmp .oloop
.return:
	pop dx
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	ret

printNum:
	pusha
	push es                 ; Save ES
	
	; Set ES to BUFFER_SEG for ALL drawing operations
	mov ax, BUFFER_SEG
	mov es, ax
	
    mov si, ScoreBuffer
	mov ax, bx              ; BX has the score
    mov cx, 0
	
.convLoop:
    xor dx, dx
    mov bx, 10
    div bx                  ; AX / 10, remainder in DX
    add dl, '0'
    push dx
    inc cx
    cmp ax, 0
    jne .convLoop

    ; write digits into buffer (reverse order)
    mov di, si
    add di, 5
.writeLoop:
    pop dx
    mov [di], dl
    inc di
    loop .writeLoop

    ; zero terminator
    mov byte [di], 0

    ; call printStr 
    mov si, ScoreBuffer
    call printStr
	
	pop es                  ; Restore ES
	popa
	ret

; ============================================
; PHASE 2 - Moving Car
; ============================================
; ============================================
; HANDLE INPUT
; ============================================
HandleInput:
    push ax
    
    ; Check if key pressed (non-blocking)
    mov ah, 0x01
    int 0x16
    jz .no_key
    
    ; Get key
    xor ah, ah
    int 0x16
    
    ; Check ESC (ASCII 27)
    cmp al, 27
    je .handle_esc
    
    ; Check left arrow
    cmp ah, 0x4B
    je .move_left
    cmp al, 'a'
    je .move_left
    cmp al, 'A'
    je .move_left
    
    ; Check right arrow
    cmp ah, 0x4D
    je .move_right
    cmp al, 'd'
    je .move_right
    cmp al, 'D'
    je .move_right
    
    jmp .no_key

.move_left:
    call ChangeCarLaneLeft
    call ChangeLaneLeft
    jmp .no_key

.move_right:
    call ChangeCarLaneRight
    call ChangeLaneRight
    jmp .no_key

.handle_esc:
    call ShowPauseMenu
    jmp .no_key

.no_key:
    pop ax
    ret
	
; ============================================
; 			  SHOW PAUSE MENU
; ============================================
ShowPauseMenu:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    
    ; First, copy current game state to buffer
    call CopyBufferToScreen
    
    ; Now work directly on video memory
    mov ax, 0xA000
    mov es, ax
    
    ; Draw shadow effect (offset by 3 pixels right and down)
    mov ax, 53        ; Y1 - shadow
    mov bx, 73        ; X1 - shadow
    mov cx, 153       ; Y2 - shadow
    mov dx, 253       ; X2 - shadow
    mov si, 0         ; Black shadow
    mov di, 0         ; Black
    call DrawPauseBox
    
    ; Draw outer border (dark blue/gray)
    mov ax, 50        ; Y1 - top position
    mov bx, 70        ; X1 - left position
    mov cx, 150       ; Y2 - bottom position
    mov dx, 250       ; X2 - right position
    mov si, 1         ; Dark blue fill
    mov di, 9         ; Bright blue border
    call DrawPauseBox
    
    ; Draw middle border
    mov ax, 52
    mov bx, 72
    mov cx, 148
    mov dx, 248
    mov si, 1         ; Dark blue fill
    mov di, 15        ; White border
    call DrawPauseBox
    
    ; Draw inner content area
    mov ax, 54
    mov bx, 74
    mov cx, 146
    mov dx, 246
    mov si, 1         ; Dark blue fill
    mov di, 8         ; Dark gray border
    call DrawPauseBox
    
    ; Now draw text using your printStr function
    ; Use your existing text rendering system
    
    mov si, exit_title
    call printStr
    
    mov si, exit_msg1
    call printStr
    
    mov si, exit_msg2
    call printStr
    
    mov si, exit_msg3
    call printStr
    
.wait_input:
    ; Wait for keypress
    mov ah, 0x00
    int 0x16
    
    ; Check for Y
    cmp al, 'Y'
    je .confirm_exit
    cmp al, 'y'
    je .confirm_exit
    
    ; Check for N
    cmp al, 'N'
    je .resume_game
    cmp al, 'n'
    je .resume_game
    
    ; Invalid key, wait again
    jmp .wait_input

.confirm_exit:
    mov word [Score], 0
    mov byte [CollisionDetected], 0
    mov word [CollisionCooldown], 0
    
    ; Reset player position
    mov word [PlayerX], 160
    mov word [PlayerY], 160
    mov byte [PlayerLane], 1
    mov word [TargetX], 160
    
    ; Reset red sprite car position
    mov word [car_x], 128
    mov word [car_y], 138
    mov byte [CarLane], 1
    mov word [CarTargetX], 128
    
    ; Reset enemy state
    mov byte [enemy1_active], 0
    mov word [EnemySpawnTimer], 30
    
    ; Reset coin and barrel state
    mov byte [coin_active], 0
    mov byte [barrel_active], 0
    mov word [CoinSpawnTimer], 60
    mov word [BarrelSpawnTimer], 120   
    
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    jmp ExitGame

.resume_game:
    ; Redraw the game screen
    call DrawToBuffer
    call CopyBufferToScreen
    
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; DRAW PAUSE BOX with 3D effect
; Y1 in AX, X1 in BX, Y2 in CX, X2 in DX
; Fill color in SI, Border color in DI
; ============================================
DrawPauseBox:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    
    mov bp, sp
    sub sp, 14
    
    ; Save parameters
    mov word [bp-2], ax   ; Y1
    mov word [bp-4], bx   ; X1
    mov word [bp-6], cx   ; Y2
    mov word [bp-8], dx   ; X2
    mov word [bp-10], si  ; Fill color
    mov word [bp-12], di  ; Border color
    
    ; Get border color into dl (8-bit)
    mov dx, [bp-12]
    mov byte [bp-13], dl  ; Store 8-bit border color
    
    ; Get fill color (8-bit)
    mov dx, [bp-10]
    mov byte [bp-14], dl  ; Store 8-bit fill color
    
    ; Draw thick top border (2 pixels)
    mov ax, [bp-2]
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, [bp-4]
    mov bx, ax
    mov cx, [bp-8]
    sub cx, [bp-4]
    inc cx
    mov dl, [bp-13]
    
.top_border:
    mov byte [es:bx], dl
    mov byte [es:bx+320], dl  ; Second row for thickness
    inc bx
    loop .top_border
    
    ; Draw thick bottom border (2 pixels)
    mov ax, [bp-6]
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, [bp-4]
    mov bx, ax
    mov cx, [bp-8]
    sub cx, [bp-4]
    inc cx
    mov dl, [bp-13]
    
.bottom_border:
    mov byte [es:bx], dl
    mov byte [es:bx-320], dl  ; Second row for thickness
    inc bx
    loop .bottom_border
    
    ; Draw left and right borders + fill
    mov ax, [bp-2]
    add ax, 2  ; Skip top border rows
    
.fill_rows:
    mov dx, [bp-6]
    sub dx, 2  ; Skip bottom border rows
    cmp ax, dx
    jge .done
    
    ; Calculate row offset
    push ax
    push dx
    mov dx, 320
    mul dx
    pop dx
    mov bx, ax
    pop ax
    
    ; Draw thick left border (2 pixels)
    push bx
    add bx, [bp-4]
    mov dl, [bp-13]
    mov byte [es:bx], dl
    mov byte [es:bx+1], dl
    pop bx
    
    ; Draw thick right border (2 pixels)
    push bx
    add bx, [bp-8]
    mov dl, [bp-13]
    mov byte [es:bx], dl
    mov byte [es:bx-1], dl
    pop bx
    
    ; Fill row interior
    push ax
    add bx, [bp-4]
    add bx, 2  ; Skip left border
    mov cx, [bp-8]
    sub cx, [bp-4]
    sub cx, 3  ; Skip both borders
    mov dl, [bp-14]
    
.fill_row:
    mov byte [es:bx], dl
    inc bx
    loop .fill_row
    
    pop ax
    inc ax
    jmp .fill_rows
    
.done:
    add sp, 14
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
; ============================================
; CHANGE LANE LEFT
; ============================================
ChangeLaneLeft:
    push ax
    
    mov al, [PlayerLane]
    cmp al, 0
    je .done
    
    dec al
    mov [PlayerLane], al
    
    cmp al, 0
    je .set_left
    mov word [TargetX], LANE_CENTER
    jmp .done
    
.set_left:
    mov word [TargetX], LANE_LEFT
    
.done:
    pop ax
    ret

; ============================================
; CHANGE LANE RIGHT
; ============================================
ChangeLaneRight:
    push ax
    
    mov al, [PlayerLane]
    cmp al, 2
    je .done
    
    inc al
    mov [PlayerLane], al
    
    cmp al, 2
    je .set_right
    mov word [TargetX], LANE_CENTER
    jmp .done
    
.set_right:
    mov word [TargetX], LANE_RIGHT
    
.done:
    pop ax
    ret
; ============================================
; UPDATE PLAYER POSITION (SMOOTH MOVEMENT)
; ============================================
UpdatePlayerPosition:
    push ax
    push bx
    
    mov ax, [PlayerX]
    mov bx, [TargetX]
    
    cmp ax, bx
    je .done
    
    jl .move_right
    
    ; Move left
    sub ax, LANE_CHANGE_SPEED
    cmp ax, bx
    jge .update
    mov ax, bx
    jmp .update
    
.move_right:
    ; Move right
    add ax, LANE_CHANGE_SPEED
    cmp ax, bx
    jle .update
    mov ax, bx
    
.update:
    mov [PlayerX], ax
    
.done:
    pop bx
    pop ax
    ret
	
; ============================================
; UPDATE SCROLLING (MOVE OBJECTS DOWN)
; ============================================
UpdateScrolling:
    push ax
    push bx
    
    ; Update road line animation
    mov ax, [RoadLineOffset]
    add ax, [ScrollSpeed]
    cmp ax, 20                  ; Reset after 20 pixels (dash + gap)
    jl .no_reset_line
    sub ax, 20
.no_reset_line:
    mov [RoadLineOffset], ax
    
    ; ===== Update tree1 position (LEFT SIDE) =====
    mov ax, [tree1_y]
    add ax, [ScrollSpeed]
    cmp ax, 200                 ; If beyond screen bottom
    jl .tree1_ok
    mov ax, -64                 ; Reset to above screen (negative)
.tree1_ok:
    mov [tree1_y], ax
    
    ; ===== Update tree2 position (RIGHT SIDE) =====
    mov ax, [tree2_y]
    add ax, [ScrollSpeed]
    cmp ax, 200                 ; If beyond screen bottom
    jl .tree2_ok
    mov ax, -64                 ; Reset to above screen
.tree2_ok:
    mov [tree2_y], ax
    
    ; ===== Update stone positions =====
    mov ax, [stone1_y]
    add ax, [ScrollSpeed]
    cmp ax, 200
    jl .stone1_ok
    mov ax, -20                 ; Reset above screen
.stone1_ok:
    mov [stone1_y], ax
    
    mov ax, [stone2_y]
    add ax, [ScrollSpeed]
    cmp ax, 200
    jl .stone2_ok
    mov ax, -20
.stone2_ok:
    mov [stone2_y], ax
    
    mov ax, [stone3_y]
    add ax, [ScrollSpeed]
    cmp ax, 200
    jl .stone3_ok
    mov ax, -20
.stone3_ok:
    mov [stone3_y], ax
    
    mov ax, [stone4_y]
    add ax, [ScrollSpeed]
    cmp ax, 200
    jl .stone4_ok
    mov ax, -20
.stone4_ok:
    mov [stone4_y], ax
	
	; ===== Update coin position =====
    cmp byte [coin_active], 1
    jne .skip_coin_update
    mov ax, [coin_y]
    add ax, [ScrollSpeed]
    cmp ax, 170                 ; If beyond screen bottom
    jl .coin_ok
    mov byte [coin_active], 0   ; Deactivate
    jmp .skip_coin_update
.coin_ok:
    mov [coin_y], ax
.skip_coin_update:
    
    ; ===== Update barrel position =====
    cmp byte [barrel_active], 1
    jne .skip_barrel_update
    mov ax, [barrel_y]
    add ax, [ScrollSpeed]
    cmp ax, 180                 ; If beyond screen bottom
    jl .barrel_ok
    mov byte [barrel_active], 0 ; Deactivate
    jmp .skip_barrel_update
.barrel_ok:
    mov [barrel_y], ax
.skip_barrel_update:
    
    ; ===== Handle spawn timers =====
    ;Coin spawn timer
    dec word [CoinSpawnTimer]
    cmp word [CoinSpawnTimer], 0
    jg .no_coin_spawn
    call SpawnCoin
.no_coin_spawn:
    
    ; Barrel spawn timer
    dec word [BarrelSpawnTimer]
    cmp word [BarrelSpawnTimer], 0
    jg .no_barrel_spawn
    call SpawnBarrel
.no_barrel_spawn:

    pop bx
    pop ax
    ret
	
; ============================================
; UTILITY FUNCTIONS
; ============================================

InitVideo:
    push ax
    mov ax, 0013h       ; VGA Mode 13h
    int 10h
    mov ax, 0A000h
    mov es, ax
    pop ax
    ret

; ============================================
; DRAW SCROLLING STONES (IMPROVED)
; ============================================
DrawScrollingStones:
    push ax
    push bx
    
    ; Left side stones 
    ; Stone group 1
    mov ax, 40
    mov bx, [stone1_y]
    cmp bx, 0 ; -20
    jl .skip_stone1
    cmp bx, 190
    jge .skip_stone1
    call DrawLargeStone
    
    ; Draw second instance if stone is partially visible at top
    cmp bx, 0
    jge .skip_stone1_top
    push bx
    add bx, 220
    call DrawLargeStone
    pop bx
.skip_stone1_top:
.skip_stone1:
    
    mov ax, 55
    mov bx, [stone1_y]
    add bx, 40
    cmp bx, 190
    jl .stone1b_ok
    sub bx, 220
.stone1b_ok:
    cmp bx, 0
    jl .skip_stone1b
    cmp bx, 190
    jge .skip_stone1b
    call DrawStone
    
    ; Draw second instance if stone is partially visible at top
    cmp bx, 0
    jge .skip_stone1b_top
    push bx
    add bx, 220
    call DrawStone
    pop bx
.skip_stone1b_top:
.skip_stone1b:
    
    ; Stone group 2
    mov ax, 15
    mov bx, [stone2_y]
    cmp bx, 0
    jl .skip_stone2
    cmp bx, 190
    jge .skip_stone2
    call DrawLargeStone
    
    ; Draw second instance if stone is partially visible at top
    cmp bx, 0
    jge .skip_stone2_top
    push bx
    add bx, 220
    call DrawLargeStone
    pop bx
.skip_stone2_top:
.skip_stone2:
    
    mov ax, 30
    mov bx, [stone2_y]
    cmp bx, 0
    jl .skip_stone2b
    cmp bx, 190
    jge .skip_stone2b
    call DrawStone
    
    ; Draw second instance if stone is partially visible at top
    cmp bx, 0
    jge .skip_stone2b_top
    push bx
    add bx, 220
    call DrawStone
    pop bx
.skip_stone2b_top:
.skip_stone2b:
    
    ; Right side stones 
    ; Stone group 3
    mov ax, 285
    mov bx, [stone3_y]
    cmp bx, 0
    jl .skip_stone3
    cmp bx, 190
    jge .skip_stone3
    call DrawLargeStone
    
    ; Draw second instance if stone is partially visible at top
    cmp bx, 0
    jge .skip_stone3_top
    push bx
    add bx, 220
    call DrawLargeStone
    pop bx
.skip_stone3_top:
.skip_stone3:
    
    mov ax, 270
    mov bx, [stone3_y]
    add bx, 40
    cmp bx, 190
    jl .stone3b_ok
    sub bx, 220
.stone3b_ok:
    cmp bx, 0
    jl .skip_stone3b
    cmp bx, 190
    jge .skip_stone3b
    call DrawStone
    
    ; Draw second instance if stone is partially visible at top
    cmp bx, 0
    jge .skip_stone3b_top
    push bx
    add bx, 220
    call DrawStone
    pop bx
.skip_stone3b_top:
.skip_stone3b:
    
    ; Stone group 4
    mov ax, 295
    mov bx, [stone4_y]
    cmp bx, 0
    jl .skip_stone4
    cmp bx, 190
    jge .skip_stone4
    call DrawLargeStone
    
    ; Draw second instance if stone is partially visible at top
    cmp bx, 0
    jge .skip_stone4_top
    push bx
    add bx, 220
    call DrawLargeStone
    pop bx
.skip_stone4_top:
.skip_stone4:
    
    mov ax, 280
    mov bx, [stone4_y]
    add bx, 40
    cmp bx, 200
    jl .stone4b_ok
    sub bx, 220
.stone4b_ok:
    cmp bx, 0
    jl .skip_stone4b
    cmp bx, 190
    jge .skip_stone4b
    call DrawStone
    
    ; Draw second instance if stone is partially visible at top
    cmp bx, 0
    jge .skip_stone4b_top
    push bx
    add bx, 220
    call DrawStone
    pop bx
.skip_stone4b_top:
.skip_stone4b:
    
    pop bx
    pop ax
    ret

; ============================================
; DRAW SCROLLING TREES (STRICT BOUNDARIES)
; ============================================
DrawScrollingTrees:
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; --- Draw tree 1 (LEFT SIDE, small 32x32) ---
    mov ax, [tree1_x]
    mov bx, [tree1_y]
 
    cmp ax, 0
    jl .skip_tree1              
    cmp ax, 65                 
    jge .skip_tree1
    
    ; Check Y bounds
    cmp bx, 0
    jl .skip_tree1
    cmp bx, 165
    jge .skip_tree1
    
    ; Draw tree
    mov si, tree1_buffer
    mov cx, [tree1_width]
    mov dx, [tree1_height]
    call DrawSprite
    
.skip_tree1:
    
    ; --- Draw tree 2 (RIGHT SIDE, large 64x64) ---
    mov ax, [tree2_x]
    mov bx, [tree2_y]
    
    
    cmp ax, 255                 
    jl .skip_tree2             
    cmp ax, 319                
    jg .skip_tree2              
    
    ; Check Y bounds
    cmp bx, 0
    jl .skip_tree2
    cmp bx, 147
    jge .skip_tree2
    
    ; Draw tree
    mov si, tree2_buffer
    mov cx, [tree2_width]
    mov dx, [tree2_height]
    call DrawSprite
    
.skip_tree2:
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
; ============================================
; CHANGE RED CAR LANE LEFT
; ============================================
ChangeCarLaneLeft:
    push ax
    
    mov al, [CarLane]
    cmp al, 0
    je .done
    
    dec al
    mov [CarLane], al
    
    ; Calculate target X based on lane
    cmp al, 0
    je .set_left
    cmp al, 1
    je .set_center
    jmp .done
    
.set_left:
    mov word [CarTargetX], 74   ; Left lane (106 - 64/2)
    jmp .done
    
.set_center:
    mov word [CarTargetX], 128  ; Center lane (160 - 64/2)
    
.done:
    pop ax
    ret

; ============================================
; CHANGE RED CAR LANE RIGHT
; ============================================
ChangeCarLaneRight:
    push ax
    
    mov al, [CarLane]
    cmp al, 2
    je .done
    
    inc al
    mov [CarLane], al
    
    ; Calculate target X based on lane
    cmp al, 1
    je .set_center
    cmp al, 2
    je .set_right
    jmp .done
    
.set_center:
    mov word [CarTargetX], 128  ; Center lane (160 - 64/2)
    jmp .done
    
.set_right:
    mov word [CarTargetX], 181  ; Right lane (213 - 64/2)
    
.done:
    pop ax
    ret

; ============================================
; UPDATE RED CAR POSITION (SMOOTH MOVEMENT)
; ============================================
UpdateCarPosition:
    push ax
    push bx
    
    mov ax, [car_x]
    mov bx, [CarTargetX]
    
    cmp ax, bx
    je .done
    
    jl .move_right
    
    ; Move left
    sub ax, CAR_CHANGE_SPEED
    cmp ax, bx
    jge .update
    mov ax, bx
    jmp .update
    
.move_right:
    ; Move right
    add ax, CAR_CHANGE_SPEED
    cmp ax, bx
    jle .update
    mov ax, bx
    
.update:
    mov [car_x], ax
    
.done:
    pop bx
    pop ax
    ret
	
; ============================================
; getRandom: returns random byte in AL
; Uses system timer low word as entropy source
; ============================================
getRandom:
    push bx
    push dx
    mov ah, 0x00        ; Get system time tick (int 1Ah, AH=0)
    int 0x1A            ; CX:DX = tick count (updated 18.2x/sec)
    mov ax, dx          ; Use lower 16 bits
    ;mix with another source
    xor ax, [ScrollOffset]  ; Add scrolling offset for extra variance
    mov bx, ax
    and bx, 0x00FF      ; Keep lower 8 bits
    mov al, bl
    pop dx
    pop bx
    ret
; ============================================
; UPDATE ENEMY CARS
; ============================================
UpdateEnemies:
    push ax
    push bx

    ; --- Decrement spawn timer ---
    cmp word [EnemySpawnTimer], 0
    jg .skip_spawn
    
    ; Reset timer (randomize next spawn time 20-60)
    call getRandom
    and ax, 0x001F      ; 0-31
    add ax, 20          ; 20-51
    mov [EnemySpawnTimer], ax

    ; --- Try to spawn a new enemy if inactive ---
    cmp byte [enemy1_active], 0
    jne .skip_spawn

    ; Pick random enemy type
    call GetRandomEnemyType
    
    ; Pick random lane: 0, 1, or 2
    call getRandom
    and ax, 0x0003      ; 0-3
    cmp ax, 3
    jl .valid_lane
    mov ax, 2           ; Remap 3 → 2
.valid_lane:
    
    ; Convert lane to X position based on enemy type
    mov bl, [CurrentEnemyType]
    cmp bl, ENEMY_RED_CAR
    je .spawn_red_car
    cmp bl, ENEMY_YELLOW_CAR
    je .spawn_yellow_car
    ; else spawn truck
    
.spawn_truck:
    ; Truck is 24 pixels wide
    cmp ax, 0
    je .truck_left
    cmp ax, 1
    je .truck_center
    ; else right
    mov word [enemy1_x], LANE_RIGHT - 2   
    jmp .spawn_done
.truck_left:
    mov word [enemy1_x], LANE_LEFT - 2    
    jmp .spawn_done
.truck_center:
    mov word [enemy1_x], LANE_CENTER - 2  
    jmp .spawn_done

.spawn_yellow_car:
    ; Yellow car is 24 pixels wide (same as truck)
    cmp ax, 0
    je .yellow_left
    cmp ax, 1
    je .yellow_center
    ; else right
    mov word [enemy1_x], LANE_RIGHT - 2
    jmp .spawn_done
.yellow_left:
    mov word [enemy1_x], LANE_LEFT - 2  
    jmp .spawn_done
.yellow_center:
    mov word [enemy1_x], LANE_CENTER - 2 
    jmp .spawn_done

.spawn_red_car:
    ; Red car is 64 pixels wide
    cmp ax, 0
    je .red_left
    cmp ax, 1
    je .red_center
    ; else right
    mov word [enemy1_x], LANE_RIGHT - 32   
    jmp .spawn_done
.red_left:
    mov word [enemy1_x], LANE_LEFT - 32   
    jmp .spawn_done
.red_center:
    mov word [enemy1_x], LANE_CENTER - 32 

.spawn_done:
    mov word [enemy1_y], 0               ; Start above screen
    mov byte [enemy1_active], 1

.skip_spawn:
    dec word [EnemySpawnTimer]

    ; --- Move existing enemy down ---
    cmp byte [enemy1_active], 1
    jne .done

    mov ax, [enemy1_y]
    add ax, [ScrollSpeed]   ; Same speed as background
    mov [enemy1_y], ax

    ; Deactivate if off bottom
    cmp ax, 150
    jl .done
    mov byte [enemy1_active], 0

.done:
    pop bx
    pop ax
    ret
	
; ============================================
; 			 CHECK COLLISIONS
; ============================================
CheckCollisions:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    ; ===== ALWAYS check coin collision first (no cooldown) =====
    cmp byte [coin_active], 1
    jne .skip_coin_check
    call CheckCoinCollision
    
.skip_coin_check:
    
    ; ===== ALWAYS check barrel collision (no cooldown) =====
    cmp byte [barrel_active], 1
    jne .skip_barrel_check
    call CheckBarrelCollision
    
.skip_barrel_check:
    
    ; ===== Check collision cooldown for enemies =====
    cmp word [CollisionCooldown], 0
    jle .check_enemy_active
    dec word [CollisionCooldown]
    jmp .no_collision
    
.check_enemy_active:
    ; Only check enemy if active
    cmp byte [enemy1_active], 1
    jne .no_collision
    
    ; ======================================
    ; COMPUTE PLAYER BOUNDING BOX (YELLOW CAR)
    ; ======================================
    ; Yellow car dimensions: 24x30 (centered at PlayerX)
    mov ax, [PlayerX]
    sub ax, 5                ; Left edge (centered at PlayerX)
    mov bx, ax
    add bx, 28                ; Right edge (PlayerX - 12 + 24)
    mov cx, [PlayerY]         ; Top edge
    mov dx, cx
    add dx, 30                ; Bottom edge (PlayerY + 30)
    
    ; Save player coordinates
    push ax
    push bx
    
    ; ======================================
    ; COMPUTE ENEMY BOUNDING BOX
    ; ======================================
    mov si, [enemy1_x]        ; SI = enemy_left
    mov di, [enemy1_y]        ; DI = enemy_top
    
    ; Compute enemy_right based on type
    mov al, [CurrentEnemyType]
    cmp al, ENEMY_RED_CAR
    je .enemy_red_width
    cmp al, ENEMY_YELLOW_CAR
    je .enemy_yellow_width
    ; Truck width (24px)
    add si, 40                ; SI now = enemy_right
    jmp .compute_enemy_bottom
.enemy_yellow_width:
    add si, 40                ; Yellow car width (24px)
    jmp .compute_enemy_bottom
.enemy_red_width:
    add si, 52                ; Red car width (64px)
    
.compute_enemy_bottom:
    ; Compute enemy_bottom
    mov al, [CurrentEnemyType]
    cmp al, ENEMY_RED_CAR
    je .enemy_red_height
    cmp al, ENEMY_YELLOW_CAR
    je .enemy_yellow_height
    ; Truck height (30px)
    add di, 45                ; DI now = enemy_bottom
    jmp .restore_player_coords
.enemy_yellow_height:
    add di, 45                ; Yellow car height (30px)
    jmp .restore_player_coords
.enemy_red_height:
    add di, 68                ; Red car height (64px)
    
.restore_player_coords:
    pop bx                    ; Restore player_right
    pop ax                    ; Restore player_left
    
    ; ======================================
    ; AABB COLLISION TEST
    ; ======================================
    ; Test 1: player_left < enemy_right?
    cmp ax, si
    jge .no_collision         ; player_left >= enemy_right (no overlap)
    
    ; Test 2: player_right > enemy_left?
    mov word [temp_collision], ax  ; Save player_left
    mov ax, [enemy1_x]        ; Get enemy_left
    cmp bx, ax
    mov ax, [temp_collision]  ; Restore player_left
    jle .no_collision         ; player_right <= enemy_left (no overlap)
    
    ; Test 3: player_top < enemy_bottom?
    cmp cx, di
    jge .no_collision         ; player_top >= enemy_bottom (no overlap)
    
    ; Test 4: player_bottom > enemy_top?
    mov word [temp_collision], ax  ; Save player_left
    mov ax, [enemy1_y]        ; Get enemy_top
    cmp dx, ax
    mov ax, [temp_collision]  ; Restore player_left
    jle .no_collision         ; player_bottom <= enemy_top (no overlap)
    
    ; ALL TESTS PASSED - COLLISION DETECTED!
    call HandleCollision
    jmp .done
    
.no_collision:
    mov byte [CollisionDetected], 0
    
.done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
; ============================================
; HANDLE COLLISION
; ============================================
HandleCollision:
    push ax
    
    mov byte [CollisionDetected], 1
    
    ; Decrease lives
    dec byte [Lives]
    
    ; Check if game over
    cmp byte [Lives], 0
    jle .game_over
    
    ; Set collision cooldown (60 frames = ~1 second)
    mov word [CollisionCooldown], 30
    
    ; Remove the enemy car
    mov byte [enemy1_active], 0
    
    jmp .done
    
.game_over:
    call GameOver
    
.done:
    pop ax
    ret
; ============================================
; GET RANDOM ENEMY TYPE
; Returns: AL = random enemy type (0-2)
; ============================================
GetRandomEnemyType:
    push bx
    
    call getRandom      ; Get random number 0-255
    and ax, 0x0003     ; 0-3
    cmp ax, 3
    jl .valid_type
    mov ax, 2          ; Remap 3 → 2
.valid_type:
    mov [CurrentEnemyType], al
    
    pop bx
    ret
	
; ============================================
; DRAW TNT (16x24 pixels) - Classic game style
; Input: AX = X position, BX = Y position
; ============================================
DrawTNT:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    mov si, ax          ; Save X position
    
    ; TNT is 16x24 pixels
    ; Colors: 4=Red body, 0=Black outline, 14=Yellow text, 6=Brown fuse
    
    ; ===== Row 1-2: Fuse with curve =====
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 8
    mov di, ax
    
    ; Fuse (brown) - starting from right side
    mov byte [es:di], 6     ; Brown fuse
    inc di
    mov byte [es:di], 6
    inc di
    mov byte [es:di], 6
    
    ; Row 2: Fuse curve
    inc bx
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 7
    mov di, ax
    
    mov byte [es:di], 6
    inc di
    mov byte [es:di], 6
    inc di
    mov byte [es:di], 6
    inc di
    mov byte [es:di], 6
    dec bx  ; Restore original Y
    
    ; ===== Row 3-4: Top of TNT (black outline) =====
    push bx
    add bx, 2
    mov dx, 2
.top_outline:
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 2
    mov di, ax
    
    pop dx
    
    ; Black outline (12 pixels wide)
    mov cx, 12
    mov al, 0
    rep stosb
    
    inc bx
    dec dx
    jnz .top_outline
    pop bx
    
    ; ===== Row 5-18: Main body with letters =====
    push bx
    add bx, 4
    mov dx, 14         ; 14 rows for main body
.body:
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    mov di, ax
    
    pop dx
    
    ; Each row: black, red body, black
    mov byte [es:di+2], 0   ; Left outline
    mov byte [es:di+3], 4   ; Red body
    mov byte [es:di+4], 4
    mov byte [es:di+5], 4
    mov byte [es:di+6], 4
    mov byte [es:di+7], 4
    mov byte [es:di+8], 4
    mov byte [es:di+9], 4
    mov byte [es:di+10], 4
    mov byte [es:di+11], 4
    mov byte [es:di+12], 4
    mov byte [es:di+13], 4
    mov byte [es:di+14], 0   ; Right outline
    
    ; Add TNT letters on specific rows
    cmp dx, 10              ; Row for first T
    je .draw_t1
    cmp dx, 8               ; Row for N  
    je .draw_n
    cmp dx, 6               ; Row for second T
    je .draw_t2
    jmp .next_row
    
.draw_t1:
    ; First T (top bar)
    mov byte [es:di+5], 14  ; Yellow
    mov byte [es:di+6], 14
    mov byte [es:di+7], 14
    mov byte [es:di+8], 14
    mov byte [es:di+9], 14
    jmp .next_row
    
.draw_n:
    ; N letter
    mov byte [es:di+5], 14  ; Left bar
    mov byte [es:di+6], 0   ; Space
    mov byte [es:di+7], 14  ; Diagonal
    mov byte [es:di+8], 0   ; Space
    mov byte [es:di+9], 14  ; Right bar
    jmp .next_row
    
.draw_t2:
    ; Second T (top bar)
    mov byte [es:di+5], 14  ; Yellow
    mov byte [es:di+6], 14
    mov byte [es:di+7], 14
    mov byte [es:di+8], 14
    mov byte [es:di+9], 14
    
.next_row:
    inc bx
    dec dx
    jnz .body
    pop bx
    
    ; ===== Row 19-20: T stem continuation =====
    push bx
    add bx, 18
    mov dx, 2
.t_stem:
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    mov di, ax
    
    pop dx
    
    mov byte [es:di+2], 0
    mov byte [es:di+3], 4
    mov byte [es:di+4], 4
    mov byte [es:di+5], 0
    mov byte [es:di+6], 14  ; T stem
    mov byte [es:di+7], 14
    mov byte [es:di+8], 0
    mov byte [es:di+9], 4
    mov byte [es:di+10], 4
    mov byte [es:di+11], 4
    mov byte [es:di+12], 4
    mov byte [es:di+13], 4
    mov byte [es:di+14], 0
    
    inc bx
    dec dx
    jnz .t_stem
    pop bx
    
    ; ===== Row 21-22: Bottom rounded =====
    push bx
    add bx, 20
    mov dx, 2
.bottom:
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    mov di, ax
    
    pop dx
    
    cmp dx, 2
    je .bottom_row1
    ; Bottom row 2 (smaller)
    mov byte [es:di+3], 0
    mov byte [es:di+4], 4
    mov byte [es:di+5], 4
    mov byte [es:di+6], 4
    mov byte [es:di+7], 4
    mov byte [es:di+8], 4
    mov byte [es:di+9], 4
    mov byte [es:di+10], 4
    mov byte [es:di+11], 4
    mov byte [es:di+12], 0
    jmp .bottom_done
    
.bottom_row1:
    ; Bottom row 1
    mov byte [es:di+2], 0
    mov byte [es:di+3], 4
    mov byte [es:di+4], 4
    mov byte [es:di+5], 4
    mov byte [es:di+6], 4
    mov byte [es:di+7], 4
    mov byte [es:di+8], 4
    mov byte [es:di+9], 4
    mov byte [es:di+10], 4
    mov byte [es:di+11], 4
    mov byte [es:di+12], 4
    mov byte [es:di+13], 0
    
.bottom_done:
    inc bx
    dec dx
    jnz .bottom
    pop bx
    
    ; ===== Row 23-24: Bottom tip =====
    mov ax, bx
    add ax, 22
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 6
    mov di, ax
    
    mov byte [es:di], 0
    mov byte [es:di+1], 4
    mov byte [es:di+2], 4
    mov byte [es:di+3], 4
    mov byte [es:di+4], 4
    mov byte [es:di+5], 0
    
    ; Row 24: Final tip
    inc ax
    mov di, ax
    add di, 6
    mov byte [es:di], 0
    mov byte [es:di+1], 4
    mov byte [es:di+2], 4
    mov byte [es:di+3], 0
    
    ; ===== Spark at end of fuse =====
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 10
    mov di, ax
    
    mov byte [es:di], 14    ; Yellow spark
    mov byte [es:di-1], 14   ; Add more spark pixels
    mov byte [es:di+1], 14
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
	
; ============================================
; DRAW COIN (12x12 pixels - shiny gold coin)
; Input: AX = X position, BX = Y position
; ============================================
DrawCoin:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    mov si, ax          ; Save X position
    
    ; Coin is 12x12 pixels
    ; Colors: 14=Yellow/Gold, 6=Dark gold/Brown, 15=White shine
    
    ; ===== Row 1-2: Top edge =====
    push bx
    mov dx, 2
.top_edge:
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 3           ; Center
    mov di, ax
    
    pop dx
    
    mov cx, 6
    mov al, 6           ; Dark gold edge
    rep stosb
    
    inc bx
    dec dx
    jnz .top_edge
    pop bx
    
    ; ===== Row 3: Top with shine =====
    mov ax, bx
    add ax, 2
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 2
    mov di, ax
    
    mov byte [es:di], 6     ; Dark edge
    inc di
    mov byte [es:di], 15    ; White shine
    inc di
    mov byte [es:di], 15    ; White shine
    inc di
    mov byte [es:di], 14    ; Yellow
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 6
    
    ; ===== Row 4-5: Upper body with shine =====
    push bx
    add bx, 3
    mov dx, 2
.upper:
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 1
    mov di, ax
    
    pop dx
    
    mov byte [es:di], 6
    inc di
    mov byte [es:di], 15    ; Shine
    inc di
    mov byte [es:di], 14    ; Gold
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 6
    
    inc bx
    dec dx
    jnz .upper
    pop bx
    
    ; ===== Row 6-7: Middle with star/sparkle =====
    push bx
    add bx, 5
    
    ; Row 6
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 1
    mov di, ax
    
    mov byte [es:di], 6
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 15    ; Star center
    inc di
    mov byte [es:di], 15
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 6
    
    ; Row 7
    inc bx
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 1
    mov di, ax
    
    mov byte [es:di], 6
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 15    ; Star
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 15    ; Star
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 6
    
    pop bx
    
    ; ===== Row 8-9: Lower body =====
    push bx
    add bx, 7
    mov dx, 2
.lower:
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 1
    mov di, ax
    
    pop dx
    
    mov byte [es:di], 6
    inc di
    
    mov cx, 8
    mov al, 14
    rep stosb
    
    mov byte [es:di], 6
    
    inc bx
    dec dx
    jnz .lower
    pop bx
    
    ; ===== Row 10: Bottom with shadow =====
    mov ax, bx
    add ax, 9
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 2
    mov di, ax
    
    mov byte [es:di], 6
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 14
    inc di
    mov byte [es:di], 6     ; Dark shadow
    inc di
    mov byte [es:di], 6
    inc di
    mov byte [es:di], 6
    
    ; ===== Row 11-12: Bottom edge =====
    push bx
    add bx, 10
    mov dx, 2
.bottom:
    push dx
    
    mov ax, bx
    mov dx, SCREEN_WIDTH
    mul dx
    add ax, si
    add ax, 3
    mov di, ax
    
    pop dx
    
    mov cx, 6
    mov al, 6
    rep stosb
    
    inc bx
    dec dx
    jnz .bottom
    pop bx
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
	
; ============================================
; SPAWN COIN AT RANDOM LANE
; ============================================
SpawnCoin:
    push ax
    
    ; Check if coin already active
    cmp byte [coin_active], 1
    je .done
    
    ; Randomize next spawn time
    call getRandom
    and ax, 0x003F      ; 0-63
    add ax, COIN_SPAWN_MIN
    cmp ax, COIN_SPAWN_MAX
    jle .set_coin_timer
    mov ax, COIN_SPAWN_MAX
.set_coin_timer:
    mov [CoinSpawnTimer], ax
    
    ; Pick random lane: 0, 1, or 2
    call getRandom
    and ax, 0x0003      ; 0-3
    cmp ax, 3
    jl .valid_coin_lane
    mov ax, 2           ; Remap 3 → 2
.valid_coin_lane:
    
    ; Convert lane to X position
    cmp ax, 0
    je .coin_left
    cmp ax, 1
    je .coin_center
    ; else right
    mov word [coin_x], LANE_RIGHT - 6   ; Center in right lane
    jmp .set_coin_pos
.coin_left:
    mov word [coin_x], LANE_LEFT - 6    ; Center in left lane
    jmp .set_coin_pos
.coin_center:
    mov word [coin_x], LANE_CENTER - 6  ; Center in middle lane
    
.set_coin_pos:
    mov word [coin_y], 0               ; Start above screen
    mov byte [coin_active], 1
    
.done:
    pop ax
    ret

; ============================================
; SPAWN BARREL AT RANDOM LANE
; ============================================
SpawnBarrel:
    push ax
    
    ; Check if barrel already active
    cmp byte [barrel_active], 1
    je .done
    
    ; Randomize next spawn time
    call getRandom
    and ax, 0x007F      ; 0-127
    add ax, BARREL_SPAWN_MIN
    cmp ax, BARREL_SPAWN_MAX
    jle .set_barrel_timer
    mov ax, BARREL_SPAWN_MAX
.set_barrel_timer:
    mov [BarrelSpawnTimer], ax
    
    ; Pick random lane: 0, 1, or 2
    call getRandom
    and ax, 0x0003      ; 0-3
    cmp ax, 3
    jl .valid_barrel_lane
    mov ax, 2           ; Remap 3 → 2
.valid_barrel_lane:
    
    ; Convert lane to X position
    cmp ax, 0
    je .barrel_left
    cmp ax, 1
    je .barrel_center
    ; else right
    mov word [barrel_x], LANE_RIGHT - 8   ; Center in right lane
    jmp .set_barrel_pos
.barrel_left:
    mov word [barrel_x], LANE_LEFT - 8    ; Center in left lane
    jmp .set_barrel_pos
.barrel_center:
    mov word [barrel_x], LANE_CENTER - 8  ; Center in middle lane
    
.set_barrel_pos:
    mov word [barrel_y], 0              ; Start above screen
    mov byte [barrel_active], 1
    
.done:
    pop ax
    ret
; ============================================
; 		   DRAW SCROLLING OBJECTS 
; ============================================
DrawScrollingObjects:
    push ax
    push bx
    push es
    
    ; Point to buffer segment for drawing
    mov ax, BUFFER_SEG
    mov es, ax
    
    ; Draw coin if active
    cmp byte [coin_active], 1
    jne .skip_coin
    mov ax, [coin_x]
    mov bx, [coin_y]
    call DrawCoin
.skip_coin:
    
    ; Draw barrel if active
    cmp byte [barrel_active], 1
    jne .skip_barrel
    mov ax, [barrel_x]
    mov bx, [barrel_y]
    call DrawTNT  ; Using DrawTNT for barrels as in your example
.skip_barrel:
    
    pop es
    pop bx
    pop ax
    ret	
; ============================================
;            CHECK COIN COLLISION 
; ============================================
CheckCoinCollision:
    push ax
    push bx
    push cx
    push dx

    ; Player bbox
    mov ax, [PlayerX]
    sub ax, 12        ; player_left (AX)
    mov bx, [PlayerY] ; player_top (BX)
    
    mov cx, [coin_x]
    sub cx, 6         ; coin_left (CX)
    mov dx, [coin_y]
    sub dx, 6         ; coin_top (DX)

    ; X-axis overlap check
    ; player_right > coin_left AND player_left < coin_right
    push ax
    add ax, 24        ; player_right
    cmp ax, cx        ; player_right vs coin_left
    pop ax
    jle .no_collision ; No X overlap
    
    push cx
    add cx, 12        ; coin_right
    cmp ax, cx        ; player_left vs coin_right
    pop cx
    jge .no_collision ; No X overlap

    ; Y-axis overlap check
    ; player_bottom > coin_top AND player_top < coin_bottom
    push bx
    add bx, 30        ; player_bottom
    cmp bx, dx        ; player_bottom vs coin_top
    pop bx
    jle .no_collision ; No Y overlap
    
    push dx
    add dx, 12        ; coin_bottom
    cmp bx, dx        ; player_top vs coin_bottom
    pop dx
    jge .no_collision ; No Y overlap

    ; Collision detected!
    mov byte [coin_active], 0
    add word [Score], 10

.no_collision:
    pop dx
    pop cx
    pop bx
    pop ax
    ret


; ============================================
; 		    CHECK BARREL COLLISION
; ============================================
CheckBarrelCollision:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Player bbox
    mov ax, [PlayerX]
    sub ax, 12        ; player_left
    mov bx, ax
    add bx, 24        ; player_right
    mov cx, [PlayerY] ; player_top
    mov dx, cx
    add dx, 30        ; player_bottom

    ; Barrel bbox
    mov si, [barrel_x]
    sub si, 8         ; barrel_left
    mov di, si
    add di, 16        ; barrel_right

    ; --- Y overlap check (unsigned) ---
    mov ax, [barrel_y]
    sub ax, 12        ; barrel_top
    cmp dx, ax        ; player_bottom ? barrel_top
    jb .no_barrel_collision   ; if player_bottom < barrel_top -> no overlap

    add ax, 24        ; barrel_bottom
    cmp cx, ax        ; player_top ? barrel_bottom
    jae .no_barrel_collision  ; if player_top >= barrel_bottom -> no overlap

    ; --- X overlap check (unsigned) ---
    cmp bx, si        ; player_right ? barrel_left
    jb .no_barrel_collision   ; if player_right < barrel_left -> no overlap

    mov ax, [PlayerX]
    sub ax, 12        ; player_left
    cmp ax, di        ; player_left ? barrel_right
    jae .no_barrel_collision  ; if player_left >= barrel_right -> no overlap

    ; Collision detected -> immediate effect
    mov byte [barrel_active], 0

    ; restore stack (we pushed AX above) and call GameOver
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    call GameOver
    ret

.no_barrel_collision:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; 			  	 GAME OVER
; ============================================
GameOver:
	call ShowGameOverScreen
    
    ; Wait for keypress
    mov ah, 0x00
    int 0x16
    
	; Check the user's choice
    cmp al, 'Y'
    je ResetGameState
    cmp al, 'y'
    je ResetGameState

	mov word [Score], 0
    mov byte [CollisionDetected], 0
    mov word [CollisionCooldown], 0
    
    ; Reset player position
    mov word [PlayerX], 160
    mov word [PlayerY], 160
    mov byte [PlayerLane], 1
    mov word [TargetX], 160
    
    ; Reset red sprite car position
    mov word [car_x], 128
    mov word [car_y], 138
    mov byte [CarLane], 1
    mov word [CarTargetX], 128
    
    ; Reset enemy state
    mov byte [enemy1_active], 0
    mov word [EnemySpawnTimer], 30
    
    ; Reset coin and barrel state
    mov byte [coin_active], 0
    mov byte [barrel_active], 0
    mov word [CoinSpawnTimer], 60
    mov word [BarrelSpawnTimer], 120
	
	call clrscr
	
	jmp ExitGame
	
; ============================================
; 		   SHOW Game Over SCREEN
; ============================================
ShowGameOverScreen:
    ; Set video mode 13h (320x200, 256 colors)
    mov ax, 0x0013
    int 0x10

    ; Load palette (reuse existing procedure)
    call load_palette

    ; Open intro image
    mov ax, 0x3D00
    mov dx, gameover_image
    int 0x21
    jc file_error
    mov [file_handle], ax

    ; Read file into video memory
    mov bx, [file_handle]
    mov ax, 0xA000
    mov es, ax
    xor di, di

.read_loop_intro:
    mov ah, 0x3F
    mov cx, 8192
    mov dx, buffer
    int 0x21
    jc file_error
    cmp ax, 0
    je .done
    mov cx, ax
    mov si, buffer
    rep movsb
    jmp .read_loop_intro

.done:
    ; Close file
    mov ah, 0x3E
    mov bx, [file_handle]
    int 0x21
	
	ret
; ============================================
;             RESET GAME STATE
; ============================================
ResetGameState:
    ; Reset score and game state
    mov word [Score], 0
    mov byte [CollisionDetected], 0
    mov word [CollisionCooldown], 0
    
    ; Reset player position
    mov word [PlayerX], 160
    mov word [PlayerY], 160
    mov byte [PlayerLane], 1
    mov word [TargetX], 160
    
    ; Reset red sprite car position
    mov word [car_x], 128
    mov word [car_y], 138
    mov byte [CarLane], 1
    mov word [CarTargetX], 128
    
    ; Reset enemy state
    mov byte [enemy1_active], 0
    mov word [EnemySpawnTimer], 30
    
    ; Reset coin and barrel state
    mov byte [coin_active], 0
    mov byte [barrel_active], 0
    mov word [CoinSpawnTimer], 60
    mov word [BarrelSpawnTimer], 120    
	
	pop ax
    jmp restart

; ===============================================
;              Loading - Screen 
; ===============================================
clrscr:
	pusha
	mov ax, 0xA000
	mov es, ax
	xor di, di
	mov cx, 0xFA00
	xor al, al
	rep stosb
	popa
	ret

rect:
	push ax
	push bx
	push cx
	push dx
	push di
	
	mov ax, [si]
	mov bx, 320
	mul bx
	mov di, ax
	mov ax, [si + 2]
	add di, ax

	mov cx, [si + 6]
	sub cx, [si + 2]
	inc cx
	
	mov ax, [si + 10]
	rep stosb

	add di, [si + 2]
	sub di, [si + 6]
	add di, 319
	
	mov dx, [si + 4]
	sub dx, [si]
	inc dx
	
.oloop:	
	mov ax, [si + 10]
	stosb
	
	mov cx, [si + 6]
	sub cx, [si + 2]
	dec cx
	
	mov ax, [si + 8]
	rep stosb
	
	mov ax, [si + 10]
	stosb
	
	add di, [si + 2]
	sub di, [si + 6]
	add di, 319
	
	dec dx
	jnz .oloop
	
	
	mov cx, [si + 6]
	sub cx, [si + 2]
	inc cx
	
	mov ax, [si + 10]
	rep stosb

	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	
	ret

drawPercent:
	pusha
	mov si, txt5 + 29
	call printStr
	inc byte [txt5 + 36]
	cmp byte [txt5 + 36], ':'
	jne .skip
	sub byte [txt5 + 36], 10
	cmp byte [txt5 + 35], ' '
	jne .notzero
	mov byte [txt5 + 35], '0'
.notzero:
	inc byte [txt5 + 35]
	cmp byte [txt5 + 35], ':'
	jne .skip
	sub byte [txt5 + 35], 10
	mov byte [txt5 + 34], '0'
	inc byte [txt5 + 34]
.skip:
	popa
	ret

drawMiniCar:
	push bx
	push cx
	push dx
	push si
	push di
	
	mov dh, bh
.oloop:
	mov di, [minicar]
	mov si, minicar + 2
	mov dl, 8 ; the height of the car
	call drawPercent
.iloop:
	mov cx, 15 ; the width of the car
	rep movsb
	add di, 305 ; 320 - 15
	dec dl
	jnz .iloop
	pop di
	inc word [minicar]
	push di
	push dx
	mov dl, bl
	call sleep
	pop dx
	dec dh
	jnz .oloop
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	ret

Loading_Screen:
	mov ax, 0x0013
	int 0x10
	pusha
	push cs
	pop ds
	mov ax, 0xA000
	mov es, ax
	xor ax, ax
	int 0x16
	; -----SLIDE 1-----
	mov si, txt1
	call printStr
	mov si, txt2
	call printStr
	mov si, txt3
	call printStr
	mov si, txt4
	call printStr
	mov dl, 50
	call sleep
	call clrscr
	; -----SLIDE 2-----
	mov cx, 3
	mov si, txt5
	call printStr
	mov si, box1
	call rect
	mov si, loadingDelay
.slide2:
	push si
	mov si, txt5 + 20
	call printStr
	pop si
	push si
	mov bx, [si]
	call drawMiniCar
	mov si, txt5 + 13
	call printStr
	pop si
	add si, 2
	push si
	mov bx, [si]
	call drawMiniCar
	mov si, txt5 + 13
	add word [si], 6
	call printStr
	pop si
	add si, 2
	push si
	mov bx, [si]
	call drawMiniCar
	mov si, txt5 + 13
	add word [si], 6
	call printStr
	pop si
	add si, 2
	push si
	mov bx, [si]
	call drawMiniCar
	mov si, txt5 + 13
	sub word [si], 12
	pop si
	add si, 2
	loop .slide2
	call drawPercent
	mov dl, 100
	call sleep
	
	mov word [minicar], 100 * 320 + 102
	mov byte [txt5 + 36], '0'
	mov byte [txt5 + 35], ' '
	mov byte [txt5 + 34], ' '
	
	call clrscr

	popa
	ret
	
; ============================================
; 		 DIFFICULTY SELECTION SCREEN
; ============================================
ShowDifficultyScreen:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    
    call clrscr
  
    ; Draw title box
    mov ax, 35
    mov bx, 60
    mov cx, 45
    mov dx, 260
    mov si, 0            ; Fill color (black)
    mov di, 14           ; Border color (yellow)
    call DrawBox
    
    ; Draw option boxes
    ; Easy box
    mov ax, 75
    mov bx, 40
    mov cx, 95
    mov dx, 280
    mov si, 0
    mov di, 10           ; Green border
    call DrawBox
    
    ; Medium box
    mov ax, 95
    mov bx, 40
    mov cx, 115
    mov dx, 280
    mov si, 0
    mov di, 14           ; Yellow border
    call DrawBox
    
    ; Hard box
    mov ax, 115
    mov bx, 40
    mov cx, 135
    mov dx, 280
    mov si, 0
    mov di, 12           ; Red border
    call DrawBox
    
    ; Draw instruction box
    mov ax, 155
    mov bx, 30
    mov cx, 165
    mov dx, 290
    mov si, 0
    mov di, 15           ; White border
    call DrawBox
    
    ; Draw all text
    mov si, diff_title
    call printStr
    
    mov si, diff_option1
    call printStr
    
    mov si, diff_option2
    call printStr
    
    mov si, diff_option3
    call printStr
    
    mov si, diff_desc1
    call printStr
    
    mov si, diff_desc2
    call printStr
    
    mov si, diff_desc3
    call printStr
    
    mov si, diff_instruction
    call printStr
    
    ; Initialize selection to Medium
    mov byte [SelectedOption], 1
    
.input_loop:
    ; Draw selector
    call DrawSelector
    
    ; Wait for key
    mov ah, 0x00
    int 0x16
    
    ; Check for UP arrow (scan code 0x48)
    cmp ah, 0x48
    je .move_up
    
    ; Check for DOWN arrow (scan code 0x50)
    cmp ah, 0x50
    je .move_down
    
    ; Check for '1' key
    cmp al, '1'
    je .select_easy
    
    ; Check for '2' key
    cmp al, '2'
    je .select_medium
    
    ; Check for '3' key
    cmp al, '3'
    je .select_hard
    
    ; Check for ENTER (scan code 0x1C)
    cmp ah, 0x1C
    je .confirm_selection
    
    jmp .input_loop

.move_up:
    ; Clear previous selector
    call ClearSelector
    
    ; Move up (wrap around)
    dec byte [SelectedOption]
    cmp byte [SelectedOption], 0
    jge .input_loop
    mov byte [SelectedOption], 2
    jmp .input_loop

.move_down:
    ; Clear previous selector
    call ClearSelector
    
    ; Move down (wrap around)
    inc byte [SelectedOption]
    cmp byte [SelectedOption], 3
    jl .input_loop
    mov byte [SelectedOption], 0
    jmp .input_loop

.select_easy:
    call ClearSelector
    mov byte [SelectedOption], 0
    jmp .input_loop

.select_medium:
    call ClearSelector
    mov byte [SelectedOption], 1
    jmp .input_loop

.select_hard:
    call ClearSelector
    mov byte [SelectedOption], 2
    jmp .input_loop

.confirm_selection:
    ; Set difficulty based on selection
    mov al, [SelectedOption]
    mov [DifficultyLevel], al
    call ApplyDifficulty
    
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; 			DRAW SELECTOR ARROW
; ============================================
DrawSelector:
    push ax
    push bx
    push cx
    push dx
    push di
    push es
    
    mov ax, 0xA000
    mov es, ax
    
    ; Calculate Y position based on selected option
    mov al, [SelectedOption]
    mov bl, 20           ; Spacing between options
    mul bl
    add ax, 85           ; Base Y position
    mov bx, ax           ; Y position in BX
    
    ; X position for arrow
    mov cx, 25           ; X position
    
    ; Calculate video memory offset
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, cx
    mov di, ax
    
    ; Draw arrow (simple > symbol)
    mov byte [es:di], 15     ; White color
    mov byte [es:di+1], 15
    mov byte [es:di+320], 15
    mov byte [es:di+321], 15
    mov byte [es:di+640], 15
    mov byte [es:di+641], 15
	
    
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; CLEAR SELECTOR ARROW
; ============================================
ClearSelector:
    push ax
    push bx
    push cx
    push dx
    push di
    push es
    
    mov ax, 0xA000
    mov es, ax
    
    ; Calculate Y position based on selected option
    mov al, [SelectedOption]
    mov bl, 20
    mul bl
    add ax, 85
    mov bx, ax
    
    mov cx, 25
    
    ; Calculate offset
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, cx
    mov di, ax
    
    ; Clear arrow
    mov byte [es:di], 0
    mov byte [es:di+1], 0
    mov byte [es:di+320], 0
    mov byte [es:di+321], 0
    mov byte [es:di+640], 0
    mov byte [es:di+641], 0
    
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; APPLY DIFFICULTY SETTINGS
; ============================================
ApplyDifficulty:
    push ax
    push bx
    
    mov al, [DifficultyLevel]
    
    cmp al, 0            ; Easy
    je .set_easy
    
    cmp al, 1            ; Medium
    je .set_medium
    
    cmp al, 2            ; Hard
    je .set_hard
    
    jmp .done

.set_easy:
    ; Lives: 5
    mov byte [Lives], 3
    
    ; Scroll Speed: Slow (3 pixels)
    mov word [ScrollSpeed], 3
    
    ; Enemy spawn: Less frequent (60-100 frames)
    mov word [ENEMY_SPAWN_MIN], 60
    mov word [ENEMY_SPAWN_MAX], 100
    mov word [EnemySpawnTimer], 60
    
    ; Coin spawn: More frequent
    mov word [CoinSpawnTimer], 40
    
    ; Barrel spawn: Less frequent
    mov word [BarrelSpawnTimer], 150
    
    jmp .done

.set_medium:
    ; Lives: 3
    mov byte [Lives], 2
    
    ; Scroll Speed: Normal (5 pixels)
    mov word [ScrollSpeed], 5
    
    ; Enemy spawn: Normal (30-60 frames)
    mov word [ENEMY_SPAWN_MIN], 30
    mov word [ENEMY_SPAWN_MAX], 60
    mov word [EnemySpawnTimer], 40
    
    ; Coin spawn: Normal
    mov word [CoinSpawnTimer], 60
    
    ; Barrel spawn: Normal
    mov word [BarrelSpawnTimer], 120
    
    jmp .done

.set_hard:
    ; Lives: 1
    mov byte [Lives], 1
    
    ; Scroll Speed: Fast (8 pixels)
    mov word [ScrollSpeed], 9
    
    ; Enemy spawn: Very frequent (15-30 frames)
    mov word [ENEMY_SPAWN_MIN], 10 ;15
    mov word [ENEMY_SPAWN_MAX], 25 ; 30
    mov word [EnemySpawnTimer], 15 ; 20
    
    ; Coin spawn: Less frequent
    mov word [CoinSpawnTimer], 80
    
    ; Barrel spawn: More frequent
    mov word [BarrelSpawnTimer], 50
    
.done:
    pop bx
    pop ax
    ret

; ============================================
; DRAW BOX (Helper function)
; Y1 in AX, X1 in BX, Y2 in CX, X2 in DX
; Fill color in SI, Border color in DI
; ============================================
DrawBox:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    push bp
    
    mov bp, sp
    
    ; Save parameters on stack
    sub sp, 10
    mov word [bp-2], ax  ; Save Y1
    mov word [bp-4], bx  ; Save X1
    mov word [bp-6], cx  ; Save Y2
    mov word [bp-8], dx  ; Save X2
    mov word [bp-10], si ; Save fill color
    mov word [bp-12], di ; Save border color
    
    mov ax, 0xA000
    mov es, ax
    
    ; Get border color into dl (8-bit)
    mov dx, [bp-12]
    
    ; Draw top border
    mov ax, [bp-2]       ; Y1
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, [bp-4]       ; X1
    mov bx, ax
    mov cx, [bp-8]
    sub cx, [bp-4]       ; Width
	
.top_border:
    mov byte [es:bx], dl
    inc bx
    loop .top_border
    
    ; Draw bottom border
    mov ax, [bp-6]       ; Y2
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, [bp-4]
    mov bx, ax
    mov cx, [bp-8]
    sub cx, [bp-4]
	
	add bx, 640
.bottom_border:
    mov byte [es:bx], dl
    inc bx
    loop .bottom_border
    
    ; Get fill color into dl (8-bit)
    mov dx, [bp-10]
    
    ; Fill interior
    mov ax, [bp-2]
    inc ax               ; Y1 + 1
.fill_loop:
    cmp ax, [bp-6]
    jge .done_fill
    
    push ax
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, [bp-4]
    mov bx, ax
    pop ax
    
    mov cx, [bp-8]
    sub cx, [bp-4]
    
    push ax
.fill_row:
    mov byte [es:bx], dl
    inc bx
    loop .fill_row
    pop ax
    
    inc ax
    jmp .fill_loop
    
.done_fill:
    add sp, 10
    pop bp
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
; ============================================
; DRAW HEART AT POSITION
; Input: AX = Y position, BX = X position
; Uses: BUFFER_SEG or VIDEO_SEG
; ============================================
DrawHeart:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    
    ; Set segment (use BUFFER_SEG for buffered, 0xA000 for direct)
    mov dx, BUFFER_SEG
    mov es, dx
    
    ; Calculate screen offset
    push bx             ; Save X
    mov dx, SCREEN_WIDTH
    mul dx              ; AX = Y * 320
    pop bx
    add ax, bx          ; AX = Y * 320 + X
    mov di, ax          ; DI = screen offset
    
    ; Load heart sprite
    mov si, heart_sprite
    mov cx, 8           ; 8 rows
    
.draw_row:
    push cx
    push di
    
    mov cx, 8           ; 8 pixels per row
    
.draw_pixel:
    lodsb               ; Load pixel color
    cmp al, 0           ; Check if transparent
    je .skip_pixel
    
    mov [es:di], al     ; Draw pixel
    
.skip_pixel:
    inc di
    loop .draw_pixel
    
    pop di
    add di, SCREEN_WIDTH ; Move to next row
    pop cx
    loop .draw_row
	
    
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
	
DrawLivesDisplay:
    push ax
    push bx
    push cx
    push si
    
    ; Draw "LIVES:" label
    mov si, lives_label
    call printStr
    
    ; Get number of lives
    xor cx, cx
    mov cl, [Lives]
    
    ; Check if no lives
    cmp cx, 0
    je .done
    
    ; Starting position for hearts
    mov ax, 10          ; Y position
    mov bx, 45          ; X position (after "LIVES:")
    
.draw_heart_loop:
    push cx
    push bx
    
    call DrawHeart
    
    pop bx
    pop cx
    
    ; Space between hearts
    add bx, 10
    
    loop .draw_heart_loop
    
.done:
    pop si
    pop cx
    pop bx
    pop ax
    ret
	
; ============================================
; LOAD ALL CAR SPRITES
; Call this after Loading_Screen
; ============================================
LoadAllCars:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    ; Load Car 1
    mov si, car1_filename
    mov di, car1_buffer
    call LoadCarSprite
    
    ; Load Car 2
    mov si, car2_filename
    mov di, car2_buffer
    call LoadCarSprite
    
    ; Load Car 3
    mov si, car3_filename
    mov di, car3_buffer
    call LoadCarSprite
    
    ; Load Car 4
    mov si, car4_filename
    mov di, car4_buffer
    call LoadCarSprite
    
    ; Load Car 5
    mov si, car5_filename
    mov di, car5_buffer
    call LoadCarSprite
    
    ; Load Car 6
    mov si, car6_filename
    mov di, car6_buffer
    call LoadCarSprite
   
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; LOAD SINGLE CAR SPRITE
; SI = filename pointer
; DI = destination buffer
; ============================================
LoadCarSprite:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    ; Open file
    mov ax, 0x3D00      ; Open file for reading
    mov dx, si          ; Filename
    int 0x21
    jc .error
    mov bx, ax          ; File handle
    
    ; Read into buffer
    mov ah, 0x3F        ; Read file
    mov cx, 4096        ; Read 64x64 = 4096 bytes
    mov dx, di          ; Destination buffer
    int 0x21
    jc .error
    
    ; Close file
    mov ah, 0x3E
    int 0x21
    
    jmp .done
    
.error:
    ; Handle error (could display message)
    ; For now, just continue
    
.done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; 			CAR SELECTION SCREEN
; ============================================
ShowCarSelectionScreen:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    
    ; Clear screen
    mov ax, 0xA000
    mov es, ax
    xor di, di
    mov cx, 32000
    xor ax, ax
    rep stosw
    
    ; Initialize selection
    mov byte [CurrentCarIndex], 0
    
.main_loop:
    ; Clear screen
    mov ax, 0xA000
    mov es, ax
    xor di, di
    mov cx, 32000
    xor ax, ax
    rep stosw
    
    ; Draw title
    call DrawCarSelectionTitle
    
    ; Draw current car
    call DrawCurrentCar
    
    ; Draw car name
    call DrawCarName
    
    ; Draw car stats
    call DrawCarStats
    
    ; Draw navigation arrows
    call DrawCarArrows
    
    ; Draw instructions
    call DrawCarInstructions
    
    ; Wait for input
    mov ah, 0x00
    int 0x16
    
    ; Check LEFT arrow (0x4B)
    cmp ah, 0x4B
    je .prev_car
    
    ; Check RIGHT arrow (0x4D)
    cmp ah, 0x4D
    je .next_car
    
    ; Check ENTER (0x1C)
    cmp ah, 0x1C
    je .select_car
    
    ; Check ESC (0x01) - go back
    cmp ah, 0x01
    je .exit
    
    jmp .main_loop

.prev_car:
    dec byte [CurrentCarIndex]
    cmp byte [CurrentCarIndex], 0xFF  ; Wrapped around?
    jne .main_loop
    mov byte [CurrentCarIndex], 5      ; Wrap to last car
    jmp .main_loop

.next_car:
    inc byte [CurrentCarIndex]
    cmp byte [CurrentCarIndex], 6
    jl .main_loop
    mov byte [CurrentCarIndex], 0      ; Wrap to first car
    jmp .main_loop

.select_car:
    ; Save selected car
    mov al, [CurrentCarIndex]
    mov [SelectedCar], al
    jmp .exit

.exit:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; 		  DRAW CAR SELECTION TITLE
; ============================================
DrawCarSelectionTitle:
    push si
    
    mov si, car_title
    call printStr
    
    pop si
    ret

; ============================================
; DRAW CURRENT CAR SPRITE
; Draws the selected car in the center
; ============================================
DrawCurrentCar:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    
    mov ax, 0xA000
    mov es, ax
    
    ; Get current car buffer
    xor ax, ax
    mov al, [CurrentCarIndex]
    mov bx, 4096        ; Size of each buffer
    mul bx              ; AX = offset
    
    ; Calculate buffer address
    mov si, car1_buffer
    add si, ax
    
    ; Draw position (center of screen)
    mov ax, 70          ; Y position
    mov bx, 128         ; X position (160 - 32 for centering)
    
    ; Calculate screen offset
    push bx
    mov dx, 320
    mul dx
    pop bx
    add ax, bx
    mov di, ax
    
    ; Draw 64x64 sprite
    mov cx, 64          ; 64 rows
    
.draw_row:
    push cx
    push di
    
    mov cx, 64          ; 64 pixels per row
    
.draw_pixel:
    lodsb               ; Load pixel
    cmp al, 0           ; Check for transparency
    je .skip
    mov [es:di], al
    
.skip:
    inc di
    loop .draw_pixel
    
    pop di
    add di, 320         ; Next row
    pop cx
    loop .draw_row
    
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; 				DRAW CAR NAME
; ============================================
DrawCarName:
    push ax
    push bx
    push cx
    push si
    push di
    push es
    
    mov ax, 0xA000
    mov es, ax
    
    ; Get car name pointer based on current index
    xor ax, ax
    mov al, [CurrentCarIndex]
    mov bl, 10          ; Max name length (approximate)
    mul bl
    
    ; Calculate name address (simplified)
    mov si, car1_name
    cmp byte [CurrentCarIndex], 0
    je .draw
    mov si, car2_name
    cmp byte [CurrentCarIndex], 1
    je .draw
    mov si, car3_name
    cmp byte [CurrentCarIndex], 2
    je .draw
    mov si, car4_name
    cmp byte [CurrentCarIndex], 3
    je .draw
    mov si, car5_name
    cmp byte [CurrentCarIndex], 4
    je .draw
    mov si, car6_name
    cmp byte [CurrentCarIndex], 5
    je .draw
    
.draw:
    call printStr
	
    pop es
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; DRAW CAR STATS (Speed & Handling bars)
; ============================================
DrawCarStats:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    
    mov ax, 0xA000
    mov es, ax
    
    ; First, draw the labels
    mov si, speed_label
    call printStr
    
    mov si, handling_label
    call printStr
    
    ; Get current car stats
    xor ax, ax
    mov al, [CurrentCarIndex]
    
    ; Get speed rating
    mov si, car1_speed
    xor bx, bx
    mov bl, al
    add si, bx
    mov bl, [si]        ; BL = speed rating (1-5)
    
    ; Get handling rating
    mov si, car1_handling
    xor cx, cx
    mov cl, al
    add si, cx
    mov bh, [si]        ; BH = handling rating (1-5)
    
    ; Draw speed bar (after the "SPEED:" text)
    mov di, 155 * 320 + 100  ; Adjusted X position to be after label
    mov cl, bl                ; Speed rating
    mov dl, 14                ; Yellow for speed bar
    call DrawStatBar
    
    ; Draw handling bar (after the "HANDLING:" text)
    mov di, 165 * 320 + 100   ; Adjusted X position to be after label
    mov cl, bh                ; Handling rating
    mov dl, 10                ; Green for handling bar
    call DrawStatBar
    
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ============================================
; DRAW STAT BAR
; DI = screen position
; CL = rating (1-5)
; DL = color
; ============================================
DrawStatBar:
    push ax
    push cx
    push di
    push es
    
    ; Make sure ES points to video memory
    mov ax, 0xA000
    mov es, ax
    
    xor ch, ch          ; Clear upper byte
    
    ; Check if rating is valid (1-5)
    cmp cl, 0
    je .done
    cmp cl, 5
    jg .done
    
.draw_bars:
    ; Draw a filled rectangle for each bar unit
    push cx
    
    ; Draw top row of bar (5 pixels wide, 2 pixels tall)
    mov al, dl
    mov [es:di], al
    mov [es:di+1], al
    mov [es:di+2], al
    mov [es:di+3], al
    mov [es:di+4], al
    
    ; Draw bottom row
    mov [es:di+320], al
    mov [es:di+321], al
    mov [es:di+322], al
    mov [es:di+323], al
    mov [es:di+324], al
    
    pop cx
    
    add di, 10          ; Space between bars (increased spacing)
    loop .draw_bars
    
.done:
    pop es
    pop di
    pop cx
    pop ax
    ret

; ============================================
; 			DRAW NAVIGATION ARROWS
; ============================================
DrawCarArrows:
    push ax
    push bx
    push di
    push es
    
    mov ax, 0xA000
    mov es, ax
    
    ; Left arrow (<)
    mov di, 90 * 320 + 60
    mov al, 15
    mov [es:di], al
    mov [es:di+320], al
    mov [es:di+640], al
    
    ; Right arrow (>)
    mov di, 90 * 320 + 260
    mov [es:di], al
    mov [es:di+320], al
    mov [es:di+640], al
	
    pop es
    pop di
    pop bx
    pop ax
    ret

; ============================================
; 			  DRAW INSTRUCTIONS
; ============================================
DrawCarInstructions:
    push si
    
    ; Draw navigation instruction
    mov si, car_instruction
    call printStr
    
    ; Draw speed label
    mov si, speed_label
    call printStr
    
    ; Draw handling label
    mov si, handling_label
    call printStr
    
    pop si
    ret

; =============================================
;		   Draws User Selected Car
; =============================================
DrawSelectedCar:
;Initializing car position and area
	mov ax, [car_x]
    mov bx, [car_y]
	mov cx, [car_width]
    mov dx, [car_height]
	
	;Draw SPEEDSTER
	cmp byte[CurrentCarIndex], 0
	jne select_THUNDER
    mov si, car1_buffer
    call DrawSprite
	jmp Selected
	
	;Draw THUNDER
	select_THUNDER:
	cmp byte[CurrentCarIndex], 1
	jne select_VIPER
	mov si, car2_buffer
	call DrawSprite
	jmp Selected
	
	;Draw VIPER
	select_VIPER:
	cmp byte[CurrentCarIndex], 2
	jne select_RACER
	mov si, car3_buffer
	call DrawSprite
	jmp Selected
	
	;Draw RACER
	select_RACER:
	cmp byte[CurrentCarIndex], 3
	jne select_TRUCK
	mov si, car4_buffer
	call DrawSprite
	jmp Selected
	
	;Draw TRUCK
	select_TRUCK:
	cmp byte[CurrentCarIndex], 4
	jne select_PHOENIX
	mov ax, [PlayerX]
    mov [temp_x], ax
    mov bx, [PlayerY]
    mov [temp_y], bx
    call DrawPlayerTruck
	jmp Selected
	
	;Draw PHOENIX
	select_PHOENIX:
	cmp byte[CurrentCarIndex], 5
	jne Selected
	mov ax, [PlayerX]
    mov [temp_x], ax
    mov bx, [PlayerY]
    mov [temp_y], bx
    call DrawPlayerCar
	
Selected:
	ret
; ============================================
; HANDLE ESC KEY PRESS - SHOW EXIT CONFIRMATION
; ============================================
HandleEscPress:
    push ax
    push bx
    push cx
    push dx
    push si
    push es
    
    ; Reset ESC flag
    mov byte [esc_pressed], 0
    
    ; Draw semi-transparent overlay (draw a box)
    mov ax, BUFFER_SEG
    mov es, ax
    
    ; Draw confirmation box
    mov ax, 70
    mov bx, 100
    mov cx, 150
    mov dx, 220
    mov si, 1            ; Dark blue fill
    mov di, 14           ; Yellow border
    call DrawBox
    
    ; Copy buffer to screen to show the box
    call CopyBufferToScreen
    
    ; Draw confirmation text directly to video memory
    mov ax, 0xA000
    mov es, ax
    
    mov si, exit_title
    call printStr
    
    mov si, exit_msg1
    call printStr
    
    mov si, exit_msg2
    call printStr
    
    mov si, exit_msg3
    call printStr
    
.wait_input:
    ; Use software interrupt to get input
    mov ah, 0x00
    int 0x16            ; Wait for keypress
    
    ; Check for Y key
    cmp al, 'Y'
    je .confirm_exit
    cmp al, 'y'
    je .confirm_exit
    
    ; Check for N key
    cmp al, 'N'
    je .cancel_exit
    cmp al, 'n'
    je .cancel_exit
    
    ; Invalid key, wait again
    jmp .wait_input

.confirm_exit:
    ; Exit game
	call ResetGameState
    pop es
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    jmp ExitGame

.cancel_exit:
    ; Resume game
    mov byte [game_paused], 0
    
    ; Restore the game screen (redraw everything)
    call DrawToBuffer
    call CopyBufferToScreen
    
    pop es
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    jmp MainLoop

; ============================================
; SHOW FINAL SCORE BEFORE EXIT
; ============================================
ShowFinalScore:
    push ax
    push bx
    push cx
    push dx
    push si
    push es
    
	call clrscr
    
    ; Draw "Final Score" message
    mov si, final_score_msg
    call printStr
    
    ; Position the final score text (X = 54, Y = 3)
	mov word [ScoreBuffer], 54      ; X
	mov word [ScoreBuffer + 2], 30  ; Y (adjust as needed)
	mov byte [ScoreBuffer + 4], 15  ; White color
	
    mov bx, [Score]
    call printNum
    
    ; Wait for keypress
    mov ah, 0x00
    int 0x16
    
    pop es
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
	
; ============================================
; 			  INITIALIZE BUFFER
; ============================================
InitBuffer:
    push ax
    push es
    
    ; Clear the buffer
    mov ax, BUFFER_SEG
    mov es, ax
    xor di, di
    mov cx, 32000
    xor ax, ax
    rep stosw
    
    pop es
    pop ax
    ret

; ============================================
; DRAW TO BUFFER INSTEAD OF DIRECTLY TO SCREEN
; ============================================
DrawToBuffer:
    push es
    push ax
    
    ; Point to buffer segment instead of video memory
    mov ax, BUFFER_SEG
    mov es, ax
	
    call DrawLandscape
	call DrawLivesDisplay
    call DrawRoad
    call DrawRoadMarkings

    ; Draw scrolling stones
    call DrawScrollingStones
	call DrawScrollingTrees
	call DrawScrollingObjects
	
	;Drawing Selected Car
	call DrawSelectedCar
	
    ; Draw enemy car (if active)
    cmp byte [enemy1_active], 1
    jne .skip_enemy
	
     ; Draw based on current enemy type
    mov al, [CurrentEnemyType]
    cmp al, ENEMY_RED_CAR
    je .draw_red_car
    cmp al, ENEMY_YELLOW_CAR
    je .draw_yellow_car
    ; else draw truck
    
.draw_truck:
    ; Save enemy position to temp variables for drawing
    mov ax, [enemy1_x]
    mov bx, [enemy1_y]
    mov [temp_x], ax
    mov [temp_y], bx
    
    ; Call truck drawing function with enemy position
    call DrawPlayerTruck
    jmp .skip_enemy
    
.draw_yellow_car:
    ; Save enemy position to temp variables for drawing
    mov ax, [enemy1_x]
    mov bx, [enemy1_y]
    mov [temp_x], ax
    mov [temp_y], bx
    
    ; Call yellow car drawing function with enemy position
    call DrawPlayerCar
    jmp .skip_enemy
    
 .draw_red_car:
    ; Draw red sprite car
    mov ax, [enemy1_x]
    mov bx, [enemy1_y]
    mov si, car1_buffer
    mov cx, [car_width]
    mov dx, [car_height]
    call DrawSprite
	
.skip_enemy:

    ; Draw score area
    call DrawScoreArea
    
    pop ax
    pop es
    ret
; ============================================
; 	    COPY BUFFER TO SCREEN (DURING VSYNC)
; ============================================
CopyBufferToScreen:
    push ds
    push es
    push si
    push di
    push cx
    
    ; Source: buffer
    mov ax, BUFFER_SEG
    mov ds, ax
    xor si, si
    
    ; Destination: video memory
    mov ax, VIDEO_SEG
    mov es, ax
    xor di, di
    
    ; Copy 64000 bytes (32000 words)
    mov cx, 32000
    rep movsw               ; VERY FAST!
    
    ; Restore DS
    push cs
    pop ds
    
    pop cx
    pop di
    pop si
    pop es
    pop ds
    ret
; ============================================
; 			WAIT FOR VERTICAL SYNC
; ============================================
WaitVSync:
    push ax
    push dx
    
    mov dx, 0x03DA          ; VGA status register
    
    ; Wait until NOT in vertical retrace
.wait_not_vr:
    in al, dx
    test al, 0x08           ; Bit 3 = vertical retrace
    jnz .wait_not_vr
    
    ; Wait until IN vertical retrace
.wait_vr:
    in al, dx
    test al, 0x08
    jz .wait_vr
    
    pop dx
    pop ax
    ret
; ============================================
; 				GAME DELAY
; ============================================
GameDelay:
    push cx
    mov cx, 0x0800          ; Small delay
.delay:
    nop
    loop .delay
    pop cx
    ret

FlushKeyboardBuffer:
    mov ah, 01h          ; Check if keystroke available
    int 16h
    jz .buffer_empty     ; ZF=1 means buffer is empty
    
    mov ah, 00h          ; Read and remove keystroke
    int 16h
    jmp FlushKeyboardBuffer  ; Loop until buffer is empty
    
.buffer_empty:
    ret

ExitGame:  
	
    ; Switch to text mode
    mov ax, 0x0003
    int 0x10
    
    ; Display farewell message
    mov ah, 0x09
    mov dx, exit_farewell_msg
    int 0x21
    
    ; Terminate program
    mov ax, 0x4C00
    int 0x21