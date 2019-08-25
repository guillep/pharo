Class {
	#name : #MorphicRenderer,
	#superclass : #Object,
	#instVars : [
		'damageRecorder'
	],
	#category : #'Morphic-Core-Worlds'
}

{ #category : #accessing }
MorphicRenderer >> damageRecorder [

	^ damageRecorder 
]

{ #category : #canvas }
MorphicRenderer >> doFullRepaint [

	damageRecorder doFullRepaint
]

{ #category : #drawing }
MorphicRenderer >> drawMorph: aMorph inCanvas: aCanvas [ 
	"Redraw the damaged areas of the given canvas and clear the damage list. Return a collection of the areas that
were redrawn."

	| rectList n morphs rects validList submorphs |
	rectList := damageRecorder invalidRectsFullBounds: aMorph fullBounds.
	"sort by areas to draw largest portions first"
	rectList := rectList asArray sort: [:r1 :r2 | r1 area > r2 area].
	damageRecorder reset.
	submorphs := aMorph submorphs.
	n := submorphs size.
	morphs := OrderedCollection new: n * 2.
	rects := OrderedCollection new: n * 2.
	validList := OrderedCollection new: n * 2.
	rectList do: 
			[:dirtyRect | 
			dirtyRect allAreasOutsideList: validList
				do: 
					[:r | | mm i remnantIntersects remnants rectToFill | 
					"Experimental top-down drawing --
			Traverses top to bottom, stopping if the entire area is filled.
			If only a single rectangle remains, then continue with the reduced rectangle."

					rectToFill := r.
					remnants := OrderedCollection with: r.
					i := 1.
					[remnants isEmpty or: [i > n]] whileFalse: 
							[mm := submorphs at: i.
							((remnantIntersects := remnants select: [:each | (mm fullBounds intersects: each)]) notEmpty and: [mm visible]) 
								ifTrue: 
									[morphs addLast: mm.
									
									rects addLast: (Rectangle merging: (remnantIntersects collect: [:each | mm fullBounds intersect: each])).
									remnants removeAll: remnantIntersects.
									remnantIntersects do: [:eachIntersect | remnants addAll: (mm areasRemainingToFill: eachIntersect)].
									remnants size = 1 ifTrue: [rectToFill := remnants first].
									remnants isEmpty ifTrue: [rectToFill := nil]].
							i := i + 1].
					"Now paint from bottom to top, but using the reduced rectangles."
					rectToFill ifNotNil: [
						aCanvas clipBy: rectToFill during: [ :clippedCanvas |
							aMorph drawOn: clippedCanvas ] ].

					[morphs isEmpty] whileFalse: [
						aCanvas clipBy: rects removeLast during: [ :clippedCanvas |
							clippedCanvas fullDrawMorph: morphs removeLast ] ].
					morphs reset.
					rects reset.
					validList add: r]].
	^validList
]

{ #category : #initialization }
MorphicRenderer >> initialize [

	super initialize.
	damageRecorder:= DamageRecorder new.
]

{ #category : #'update cycle' }
MorphicRenderer >> isRenderNeededInWorld: aWorld [

	damageRecorder updateIsNeeded ifTrue: [ ^true ].
		
	aWorld hands do: [:h | 
		(h hasChanged and: [h needsToBeDrawn]) ifTrue: [^true]].
	
	^false
]

{ #category : #canvas }
MorphicRenderer >> recordDamagedRect: damageRect [

	damageRecorder ifNotNil: [damageRecorder recordInvalidRect: damageRect truncated]

]

{ #category : #canvas }
MorphicRenderer >> resetDamageRecorder [

	damageRecorder reset

]

{ #category : #canvas }
MorphicRenderer >> updateIsNeeded [

	^ damageRecorder updateIsNeeded
]
