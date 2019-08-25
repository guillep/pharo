"
I am an OS window that contains a morph inside.
Use me with:

  OSMorphicWindow openOn: aMorph

I create a new os window, and a new world inside it to contain the morph.
I subscribe myself to morphic's extraWorldList (see WorldMorph class side) to refresh myself on Morphic's ui process.

I can be used to open a full new world like this:

world := WorldMorph new.
hand := HandMorph new.
world addHand: hand.
world activeHand: hand.
world extent: 800@600.

OSMorphicWindow openOnWorld: world.

Or on a single morph like this too:

OSMorphicWindow openOn: ClyFullBrowser onDefaultEnvironment.
"
Class {
	#name : #OSMorphicWindow,
	#superclass : #AbstractWorldRenderer,
	#instVars : [
		'osWindow',
		'display',
		'kmDispatcher'
	],
	#category : #'OSWindow-Core-Morphic'
}

{ #category : #'instance creation' }
OSMorphicWindow class >> on: aMorph [

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
OSMorphicWindow class >> onWorld: aWorldMorph [

	^ self new
		root: aWorldMorph;
		yourself
]

{ #category : #'instance creation' }
OSMorphicWindow class >> openOn: aMorph [

	(self on: aMorph) open
]

{ #category : #'instance creation' }
OSMorphicWindow class >> openOnWorld: aWorld [

	(self onWorld: aWorld) open
]

{ #category : #compat }
OSMorphicWindow >> activate [

	"nothing for now"
]

{ #category : #compat }
OSMorphicWindow >> activeHand [
	"this is required because Morphic's ui process asks for it to set the ActiveHand global"
	^ world activeHand
]

{ #category : #accessing }
OSMorphicWindow >> actualScreenSize [

	^ osWindow ifNil: [ 240@120 ] ifNotNil: [ osWindow extent ]
]

{ #category : #events }
OSMorphicWindow >> canvas: aCanvas [

	"should stay here for the moment. It's called by WorldMorph >> extent: but doing nothing"
]

{ #category : #events }
OSMorphicWindow >> checkForNewScreenSize [

	(display isNil or: [display extent = self actualScreenSize]) 
		ifTrue: [ ^ self ].

	display := Form extent: self actualScreenSize depth: 32.
	osWindow renderer form: display.

	world worldState realWindowExtent: self actualScreenSize.
	world submorphs do: [ :e | e extent: self actualScreenSize ].
	self restoreMorphicDisplay.
	"force render"
	self render
]

{ #category : #events }
OSMorphicWindow >> close [

	osWindow destroy.
	WorldMorph removeExtraWorld: self
]

{ #category : #events }
OSMorphicWindow >> createWindow [

	| attributes size |
	size := world extent.
	attributes := OSWindowAttributes new.
	attributes
		extent: size;
		title: world asString;
		windowCentered:true;
		icon: (self iconNamed: #pharoBig).
	attributes preferableDriver: OSWindowDriver current.

	osWindow := OSWindow
		createWithAttributes: attributes
		eventHandler: (OSWindowMorphicEventHandler for: world).
	osWindow focus.
	
	display := Form extent: size depth: 32.
	osWindow newFormRenderer: display.
]

{ #category : #events }
OSMorphicWindow >> defer: aBlockClosure [ 

	world defer: aBlockClosure
]

{ #category : #accessing }
OSMorphicWindow >> deferUpdatesWhile: aBlock [

	aBlock value
]

{ #category : #compat }
OSMorphicWindow >> dispatchEvent: anEvent [

	world dispatchEvent: anEvent
]

{ #category : #accessing }
OSMorphicWindow >> displayMorph: aMorph [
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

{ #category : #accessing }
OSMorphicWindow >> displayWorldState: aWorldState ofWorld: aWorld submorphs: submorphs [
	"Update this world's display."

	| allDamage |
	submorphs do: [ :m | m fullBounds ].	"force re-layout if needed"

	aWorldState checkIfUpdateNeeded ifFalse: [^ self].  
	"display is already up-to-date"

	self deferUpdatesWhile: [
		self drawDuring: [ :morphicCanvas |
			allDamage := self morphicRenderer drawMorph: aWorld inCanvas: morphicCanvas.

			"repair world's damage on canvas"
			morphicCanvas finish.
			"quickly copy altered rects of canvas to Display:"	
			self updateAreas: allDamage ] ]
]

{ #category : #events }
OSMorphicWindow >> doOneCycle [

	self render
]

{ #category : #events }
OSMorphicWindow >> drawDuring: aBlock [

	osWindow isValid ifFalse: [ ^ self ].

	osWindow renderer drawDuring: aBlock.
	osWindow renderer updateAll.
]

{ #category : #compat }
OSMorphicWindow >> invalidRect: aRectangle from: aClyFullBrowser [ 
	osWindow isValid ifFalse: [ ^ self ].
	super invalidRect: aRectangle from: aClyFullBrowser
]

{ #category : #events }
OSMorphicWindow >> open [

	self createWindow.
	WorldMorph addExtraWorld: self
]

{ #category : #compat }
OSMorphicWindow >> owner [
	
	^ nil
]

{ #category : #events }
OSMorphicWindow >> render [

	osWindow isValid ifFalse: [ ^ self ].

	self displayMorph: world.
	osWindow renderer updateAll.
]

{ #category : #accessing }
OSMorphicWindow >> restoreMorphicDisplay [ 

	osWindow isValid ifFalse: [self createWindow].
	world
		extent: self actualScreenSize;
		viewBox: self viewBox;
		handsDo: [:h | h visible: true; showTemporaryCursor: nil];
		resizeBackgroundMorph;
		submorphsDo: [ :each | each displayExtentChanged ];
		fullRepaintNeeded.
			
	self morphicRenderer doFullRepaint.
	world layoutChanged.
]

{ #category : #accessing }
OSMorphicWindow >> root: aMorph [

	world := aMorph.
	world container: self.
	"aMorph worldState worldRenderer: self."
	"aMorph privateOwner: self."
]

{ #category : #accessing }
OSMorphicWindow >> updateAreas: damagedRectangles [

	osWindow renderer updateAreas: damagedRectangles immediate: false
]

{ #category : #events }
OSMorphicWindow >> windowCloseRequested [
	
	self close
]

{ #category : #accessing }
OSMorphicWindow >> world [
	^ world
]
