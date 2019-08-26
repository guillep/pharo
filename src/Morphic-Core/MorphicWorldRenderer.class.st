Class {
	#name : #MorphicWorldRenderer,
	#superclass : #MorphicRenderer,
	#instVars : [
		'handsToDraw'
	],
	#category : #'Morphic-Core-Worlds'
}

{ #category : #drawing }
MorphicWorldRenderer >> drawMorph: aWorld inCanvas: aCanvas [
	"This method handles the draw of the world morph and its hands.
	The world is drawn as any other morph.
	However, the moving hands invalidate and overlap with other morphs in a wayrather difficult to understand. The algorithm is as follows:
	
	 - step 1) the first time the world is rendered, it is first drawn entirely.
	 - step 2) then, the dirty hands are drawn, but storing the piece of canvas they overlap.
	           this causes the elements below the hands to be dirtied in the canvas.
	 
	In subsequent render cycles, if the hands have moved, the elements that were behind the hand have to be invalidated so they can be drawn back. So there is a 
	 - step 0) draw/invalidate previous hand regions before drawing anything else
	"
	| worldDamageRects handDamageRects allDamage |
	
	"step 1) draw the world morph as any other morph"
	worldDamageRects := super drawMorph: aWorld inCanvas: aCanvas.
	
	"step 2) each hand stores the piece of canvas below it and then is rendered"
	handsToDraw := aWorld worldState selectHandsToDrawForDamage: worldDamageRects.
	handDamageRects := handsToDraw collect: [ :h | h savePatchFrom: aCanvas ].
	allDamage := worldDamageRects, handDamageRects.
	handsToDraw reverseDo: [ :h | aCanvas fullDrawMorph: h ].
	
	"*make this true to flash damaged areas for testing*"
	aWorld worldState class debugShowDamage
		ifTrue: [ aWorld flashRects: allDamage color: Color black ].

	^ allDamage
]

{ #category : #drawing }
MorphicWorldRenderer >> postUpdateMorph: aWorld withDamagedAreas: damagedAreas inCanvas: aCanvas [

	"step 0) For the next cycle's correctness (and cheapness), instead of just invalidating the area, try to save some time by just copying the bytes under the hands.
	This could be further simplified in the future with the introduction of textures/layers as in SDL."
	handsToDraw do: [ :h | h restoreSavedPatchOn: aCanvas ].
]
