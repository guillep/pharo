Class {
	#name : #MorphicWorldRenderer,
	#superclass : #MorphicRenderer,
	#category : #'Morphic-Core-Worlds'
}

{ #category : #drawing }
MorphicWorldRenderer >> drawMorph: aWorld inCanvas: aCanvas [

	| worldDamageRects handsToDraw handDamageRects allDamage |

	worldDamageRects := super drawMorph: aWorld inCanvas: aCanvas.
	
	handsToDraw := aWorld worldState selectHandsToDrawForDamage: worldDamageRects.
	handDamageRects := handsToDraw collect: [ :h | h savePatchFrom: aCanvas ].
	allDamage := worldDamageRects, handDamageRects.
	
	"draw hands onto world canvas"
	handsToDraw reverseDo: [ :h | aCanvas fullDrawMorph: h ].
	
	"*make this true to flash damaged areas for testing*"
	aWorld worldState class debugShowDamage
		ifTrue: [ aWorld flashRects: allDamage color: Color black ].

	"restore world canvas under hands ??"
	"handsToDraw do: [ :h | h restoreSavedPatchOn: morphicCanvas ] "
	^ allDamage
]
