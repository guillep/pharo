"
I implement the logic to render a world.
I have different implementations to start the world.
"
Class {
	#name : #AbstractWorldRenderer,
	#superclass : #Object,
	#instVars : [
		'world',
		'alreadyActivated',
		'renderer'
	],
	#classVars : [
		'MainWorldRenderer'
	],
	#category : #'Morphic-Core-Worlds'
}

{ #category : #accessing }
AbstractWorldRenderer class >> detectCorrectOneforWorld: aWorld [

	| aRenderer |

	aWorld isMainWorld ifTrue:[
		MainWorldRenderer ifNotNil: [ ^ MainWorldRenderer ]	
	].

	(self allSubclasses sorted: [ :a :b | a priority > b priority ])
		detect: [ :aClass | aClass isApplicableFor: aWorld ]
		ifFound: [ :aClass | aRenderer := aClass forWorld: aWorld ].
		
	aWorld isMainWorld 
		ifTrue:[ ^ MainWorldRenderer := aRenderer ]
		ifFalse: [ ^ aRenderer ].
	
]

{ #category : #accessing }
AbstractWorldRenderer class >> forWorld: aWorld [

	^ self new 
		world: aWorld;
		yourself
]

{ #category : #accessing }
AbstractWorldRenderer class >> initialize [

	SessionManager default registerSystemClassNamed: self name	
]

{ #category : #accessing }
AbstractWorldRenderer class >> priority [ 

	^ 0
]

{ #category : #accessing }
AbstractWorldRenderer class >> shutDown: quitting [
	quitting
		ifFalse: [ ^ self ].

	[ MainWorldRenderer ifNotNil: [ :e | e deactivate ] ]
		ensure: [ MainWorldRenderer := nil ]
]

{ #category : #accessing }
AbstractWorldRenderer class >> startUp: isANewSession [

	isANewSession
		ifTrue: [ MainWorldRenderer := nil ]
]

{ #category : #activation }
AbstractWorldRenderer >> activate [

	alreadyActivated ifTrue: [ ^ self ].

	self doActivate.
	alreadyActivated := true
]

{ #category : #activation }
AbstractWorldRenderer >> actualScreenSize [

	self subclassResponsibility 
]

{ #category : #activation }
AbstractWorldRenderer >> deactivate [

	self subclassResponsibility 
]

{ #category : #activation }
AbstractWorldRenderer >> deferUpdatesWhile: aBlock [

	aBlock value
]

{ #category : #operations }
AbstractWorldRenderer >> displayWorldState: aWorldState ofWorld: aWorld submorphs: submorphs [
	"Update this world's display."

	| damagedAreas |
	submorphs do: [ :m | m fullBounds ].	"force re-layout if needed"

	aWorldState checkIfUpdateNeeded ifFalse: [^ self].  
	"display is already up-to-date"

	self deferUpdatesWhile: [
		self drawDuring: [ :morphicCanvas |
			damagedAreas := self morphicRenderer drawMorph: aWorld inCanvas: morphicCanvas.

			"repair world's damage on canvas"
			morphicCanvas finish.
			"quickly copy altered rects of canvas to Display:"	
			self updateAreas: damagedAreas.
			self morphicRenderer
				postUpdateMorph: aWorld
				withDamagedAreas: damagedAreas
				inCanvas: morphicCanvas ] ]
]

{ #category : #activation }
AbstractWorldRenderer >> doActivate [

	self subclassResponsibility 
]

{ #category : #operations }
AbstractWorldRenderer >> drawDuring: aBlock [

	self subclassResponsibility
]

{ #category : #accessing }
AbstractWorldRenderer >> icon: aForm [ 

	self subclassResponsibility
]

{ #category : #activation }
AbstractWorldRenderer >> initialize [

	alreadyActivated := false
]

{ #category : #rendering }
AbstractWorldRenderer >> invalidRect: aRectangle from: aMorph [

	self morphicRenderer recordDamagedRect: (aRectangle intersect: self viewBox ifNone: [ ^ self ])
]

{ #category : #rendering }
AbstractWorldRenderer >> morphicRenderer [

	^ renderer ifNil: [
		renderer := world newRenderer
			doFullRepaint;
			yourself ]
]

{ #category : #rendering }
AbstractWorldRenderer >> recordDamagedRect: damageRect [

	self morphicRenderer recordDamagedRect: damageRect
]

{ #category : #operations }
AbstractWorldRenderer >> restoreMorphicDisplay [ 

	world
		extent: self actualScreenSize;
		viewBox: self viewBox;
		handsDo: [:h | h visible: true; showTemporaryCursor: nil];
		resizeBackgroundMorph;
		submorphsDo: [ :each | each displayExtentChanged ];
		fullRepaintNeeded.
		
	world defer: [Cursor normal show].
		
	world layoutChanged.

]

{ #category : #operations }
AbstractWorldRenderer >> updateAreas: damagedRectangles [

	self subclassResponsibility
]

{ #category : #initialization }
AbstractWorldRenderer >> usableArea [

	^ self viewBox
]

{ #category : #'display box access' }
AbstractWorldRenderer >> viewBox [ 

	^ 0@0 corner: self actualScreenSize
]

{ #category : #accessing }
AbstractWorldRenderer >> world [
	^ world
]

{ #category : #accessing }
AbstractWorldRenderer >> world: anObject [
	world := anObject
]
