"
I know how to render the world in an OSWindow
"
Class {
	#name : #OSWorldRenderer,
	#superclass : #AbstractWorldRenderer,
	#instVars : [
		'osWindow',
		'display'
	],
	#category : #'OSWindow-Core-Morphic'
}

{ #category : #accessing }
OSWorldRenderer class >> isApplicableFor: aWorld [

	^ Smalltalk isHeadless and: [ CommandLineArguments new hasOption: 'interactive'  ]
]

{ #category : #'instance creation' }
OSWorldRenderer class >> on: aMorph [

	| newWorld hands |
	newWorld := WorldMorph new
		extent: aMorph extent;
		layoutPolicy: ProportionalLayout new;
		clipSubmorphs: true;
		color: Color transparent;
		borderWidth: 0.

	aMorph
		hResizing: #spaceFill;
		vResizing: #spaceFill.
	aMorph openInWorld: newWorld.

	hands := HandMorph new.
	newWorld addHand: hands.
	newWorld activeHand: hands.

	^ self onWorld: newWorld
]

{ #category : #'instance creation' }
OSWorldRenderer class >> onWorld: aWorldMorph [

	^ self new
		world: aWorldMorph;
		yourself
]

{ #category : #'instance creation' }
OSWorldRenderer class >> openOn: aMorph [

	(self on: aMorph) open
]

{ #category : #'instance creation' }
OSWorldRenderer class >> openOnWorld: aWorld [

	(self onWorld: aWorld) open
]

{ #category : #accessing }
OSWorldRenderer class >> priority [ 

	^ 2
]

{ #category : #initialization }
OSWorldRenderer >> activateCursor: aCursor withMask: maskForm [

	osWindow ifNotNil: [ osWindow setMouseCursor: aCursor mask: maskForm ]
]

{ #category : #compat }
OSWorldRenderer >> activeHand [
	"this is required because Morphic's ui process asks for it to set the ActiveHand global"
	^ world activeHand
]

{ #category : #initialization }
OSWorldRenderer >> actualScreenSize [

	^ osWindow ifNil: [ 240@120 ] ifNotNil: [ osWindow extent ]
]

{ #category : #'as yet unclassified' }
OSWorldRenderer >> canvas: aCanvas [

	"should stay here for the moment. It's called by WorldMorph >> extent: but doing nothing"
]

{ #category : #initialization }
OSWorldRenderer >> checkForNewScreenSize [

	(display isNil or: [display extent = self actualScreenSize]) 
		ifTrue: [ ^ self ].

	display := Form extent: self actualScreenSize depth: 32.
	self osWindowRenderer form: display.

	world worldState realWindowExtent: self actualScreenSize.

	world restoreMorphicDisplay.

]

{ #category : #initialization }
OSWorldRenderer >> clipboardText [
	^ osWindow clipboardText
]

{ #category : #initialization }
OSWorldRenderer >> clipboardText: aString [
	osWindow clipboardText: aString asString
]

{ #category : #events }
OSWorldRenderer >> close [

	osWindow destroy.
	WorldMorph removeExtraWorld: self
]

{ #category : #initialization }
OSWorldRenderer >> createWindow [

	| attributes initialExtent |
	initialExtent := self initialExtent.
	attributes := OSWindowAttributes new.
	attributes
		extent: initialExtent;
		title: self windowTitle;
		windowCentered:true;
		icon: (self iconNamed: #pharoBig).
	attributes preferableDriver: OSWindowDriver current.

	osWindow := OSWindow
		createWithAttributes: attributes
		eventHandler: (OSWindowMorphicEventHandler for: world).
	osWindow focus.
	
	display := Form extent: initialExtent depth: 32.
	world extent: initialExtent.
	
	world worldState doFullRepaint.
	world displayWorld.
	
	OSWindowClipboard new beDefault.
]

{ #category : #initialization }
OSWorldRenderer >> deactivate [

	osWindow ifNotNil: [ osWindow destroy. osWindow := nil ].
	display := nil.
	
]

{ #category : #initialization }
OSWorldRenderer >> deferUpdates: aBoolean [

	^ false
]

{ #category : #initialization }
OSWorldRenderer >> deferUpdatesWhile: aBlock [

	self osWindowRenderer deferUpdatesWhile: [
		super deferUpdatesWhile: aBlock ]
]

{ #category : #events }
OSWorldRenderer >> dispatchEvent: anEvent [

	world dispatchEvent: anEvent
]

{ #category : #accessing }
OSWorldRenderer >> displayMorph: aMorph [
	"Update this world's display."

	| allDamage |
	aMorph submorphs do: [ :m | m fullBounds ].	"force re-layout if needed"

	self morphicRenderer updateIsNeeded ifFalse: [^ self].  
	"display is already up-to-date"
	
	self deferUpdatesWhile: [
		self drawDuring: [ :morphicCanvas |
			allDamage := self morphicRenderer drawMorph: aMorph inCanvas: morphicCanvas.

			"repair world's damage on canvas"
			morphicCanvas finish.
			"quickly copy altered rects of canvas to Display:"	
			self updateAreas: allDamage ] ]
]

{ #category : #operations }
OSWorldRenderer >> displayWorldState: aWorldState ofWorld: aWorld submorphs: submorphs [

	osWindow ifNil: [ ^ self ].
	super displayWorldState: aWorldState ofWorld: aWorld submorphs: submorphs
]

{ #category : #initialization }
OSWorldRenderer >> doActivate [

	self createWindow
]

{ #category : #events }
OSWorldRenderer >> doOneCycle [

	self render
]

{ #category : #initialization }
OSWorldRenderer >> drawDuring: aBlock [

	self osWindowRenderer drawDuring: aBlock
]

{ #category : #operations }
OSWorldRenderer >> fullscreenMode: aValue [

	osWindow fullscreen: aValue.
	self checkForNewScreenSize.
]

{ #category : #accessing }
OSWorldRenderer >> icon: aForm [ 

	osWindow icon: aForm
]

{ #category : #initialization }
OSWorldRenderer >> initialExtent [

	^ world worldState realWindowExtent ifNil: [976@665]
]

{ #category : #events }
OSWorldRenderer >> open [

	self createWindow.
	world windowEventHandler: (OSMorphicWindowEventHandler new
		osMorphicWindow: self;
		yourself).
	WorldMorph addExtraWorld: self
]

{ #category : #initialization }
OSWorldRenderer >> osWindowRenderer [
		
	^ osWindow renderer ifNil: [
		osWindow newFormRenderer: display.
		osWindow renderer
	].
	
]

{ #category : #events }
OSWorldRenderer >> render [

	self displayMorph: world
]

{ #category : #operations }
OSWorldRenderer >> updateAreas: damagedRectangles [

	self osWindowRenderer updateAreas: damagedRectangles immediate: false
]

{ #category : #initialization }
OSWorldRenderer >> windowTitle [

	^ Smalltalk shortImageName
]

{ #category : #initialization }
OSWorldRenderer >> world: aWorld [

	world := aWorld.
	world container: self.
]
