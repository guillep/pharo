"
I am an OS window that contains a morph inside.
Use me with:

  OSMorphicWindow openOn: aMorph

I create a new os window, and a new world inside it to contain the morph.
I subscribe myself to morphic's extraWorldList (see WorldMorph class side) to refresh myself on Morphic's ui process.
"
Class {
	#name : #OSMorphicWindow,
	#superclass : #Object,
	#instVars : [
		'root',
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
	
	 ^ root activeHand
]

{ #category : #accessing }
OSMorphicWindow >> actualScreenSize [

	^ osWindow ifNil: [ 240@120 ] ifNotNil: [ osWindow extent ]
]

{ #category : #compat }
OSMorphicWindow >> beCursorOwner [
	
	"nothing?"
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

	root worldState realWindowExtent: self actualScreenSize.
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
	size := root extent.
	attributes := OSWindowAttributes new.
	attributes
		extent: size;
		title: root asString;
		windowCentered:true;
		icon: (self iconNamed: #pharoBig).
	attributes preferableDriver: OSWindowDriver current.

	osWindow := OSWindow
		createWithAttributes: attributes
		eventHandler: (OSWindowMorphicEventHandler for: self).
	osWindow focus.
	
	display := Form extent: size depth: 32.
	osWindow newFormRenderer: display.
]

{ #category : #events }
OSMorphicWindow >> defer: aBlockClosure [ 

	World defer: aBlockClosure
]

{ #category : #accessing }
OSMorphicWindow >> deferUpdatesWhile: aBlock [

	aBlock value
]

{ #category : #compat }
OSMorphicWindow >> dispatchEvent: anEvent [

	root dispatchEvent: anEvent
]

{ #category : #accessing }
OSMorphicWindow >> displayWorldState: aWorldState ofWorld: aWorld submorphs: submorphs [
	"Update this world's display."

	| handsToDraw allDamage |
	submorphs do: [ :m | m fullBounds ].	"force re-layout if needed"

	aWorldState checkIfUpdateNeeded ifFalse: [^ self].  
	"display is already up-to-date"

	self deferUpdatesWhile: [ | worldDamageRects handDamageRects |
		self drawDuring: [ :morphicCanvas |
			worldDamageRects := aWorldState drawWorld: aWorld submorphs: submorphs invalidAreasOn: morphicCanvas.
			"repair world's damage on canvas"

			handsToDraw := aWorldState selectHandsToDrawForDamage: worldDamageRects.
			handDamageRects := handsToDraw collect: [ :h | h savePatchFrom: morphicCanvas ].
			allDamage := worldDamageRects, handDamageRects.
			handsToDraw reverseDo: [ :h |  morphicCanvas fullDrawMorph: h ]. "draw hands onto world canvas"
		
			"*make this true to flash damaged areas for testing*"
			aWorldState class debugShowDamage
				ifTrue: [ aWorld flashRects: allDamage color: Color black ].

			morphicCanvas finish.
		
			"quickly copy altered rects of canvas to Display:"	
			self updateAreas: allDamage.

			"restore world canvas under hands"
			handsToDraw do: [ :h | h restoreSavedPatchOn: morphicCanvas ] ] ]
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
OSMorphicWindow >> handleEvent: anEvent [

	root handleEvent: anEvent
]

{ #category : #'compat hand' }
OSMorphicWindow >> hasSubmorphs [

	^ false
]

{ #category : #compat }
OSMorphicWindow >> invalidRect: aRectangle from: aClyFullBrowser [ 
	"nothing"
]

{ #category : #accessing }
OSMorphicWindow >> kmDispatcher [
	
	^ kmDispatcher ifNil: [ 
		kmDispatcher := KMDispatcher target: self.
		"self initializeShortcuts: kmDispatcher".
		kmDispatcher ]
]

{ #category : #compat }
OSMorphicWindow >> layoutChanged [

	"nothing"
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

{ #category : #accessing }
OSMorphicWindow >> paneColorOrNil [
	
	^nil
]

{ #category : #'compat hand' }
OSMorphicWindow >> position [
	
	^ 0 @ 0
]

{ #category : #focus }
OSMorphicWindow >> releaseKeyboardFocus: aMorph [

	self releaseMouseFocus: aMorph
]

{ #category : #asd }
OSMorphicWindow >> releaseMouseFocus: aLabelMorph [ 

	"nothing"
]

{ #category : #compat }
OSMorphicWindow >> removeAlarm: aString for: aRubCursor [ 
	"nothing"
]

{ #category : #compat }
OSMorphicWindow >> removeHaloAround: aTabMorph [ 
	"nothing"
]

{ #category : #'compat hand' }
OSMorphicWindow >> removeHaloFromClick: aMouseButtonEvent on: aClyFullBrowser [ 
	
	"nothing"
]

{ #category : #'compat hand' }
OSMorphicWindow >> removePendingBalloonFor: aClyFullBrowser [ 
	
	"nothing"
]

{ #category : #events }
OSMorphicWindow >> render [

	osWindow isValid ifFalse: [ ^ self ].

	osWindow renderer getCanvas fullDraw: root.
	"osWindow renderer getCanvas finish."
	osWindow renderer updateAll.
]

{ #category : #accessing }
OSMorphicWindow >> restoreMorphicDisplay [ 

	osWindow isValid ifFalse: [self createWindow].
	root
		extent: self actualScreenSize;
		viewBox: self viewBox;
		handsDo: [:h | h visible: true; showTemporaryCursor: nil];
		resizeBackgroundMorph;
		submorphsDo: [ :each | each displayExtentChanged ];
		fullRepaintNeeded.
			
	root layoutChanged.
]

{ #category : #accessing }
OSMorphicWindow >> root: aMorph [

	root := aMorph.
	aMorph worldState worldRenderer: self.
	aMorph privateOwner: self.
]

{ #category : #compat }
OSMorphicWindow >> startStepping: aTabBuildingIconMorph [ 
	
	"nothing"
]

{ #category : #'compat hand' }
OSMorphicWindow >> stopStepping: aFTTableMorph selector: aString [ 
	
	"nothng"
]

{ #category : #'compat hand' }
OSMorphicWindow >> submorphs [

	^ #()
]

{ #category : #compat }
OSMorphicWindow >> theme [
	^ Smalltalk ui theme
]

{ #category : #accessing }
OSMorphicWindow >> transformFrom: uberMorph [ 
	"Return a transform to be used to map coordinates in a morph above me into my childrens coordinates, or vice-versa. This is used to support scrolling, scaling, and/or rotation. This default implementation just returns my owner's transform or the identity transform if my owner is nil. 
	Note:  This method cannot be used to map into the receiver's coordinate system!"

	^IdentityTransform new
]

{ #category : #accessing }
OSMorphicWindow >> usableArea [

	^ self viewBox
]

{ #category : #accessing }
OSMorphicWindow >> viewBox [

	^ 0@0 corner: self actualScreenSize
]

{ #category : #'compat hand' }
OSMorphicWindow >> waitForClicksOrDrag: aMorph event: evt [
	"Wait for mouse button and movement events, informing aMorph about events interesting to it via callbacks.
	This message is typically sent to the Hand by aMorph when it first receives a mouse-down event.
	The callback methods invoked on aMorph (which are passed a copy of evt) are:
		#click:	sent when the mouse button goes up within doubleClickTime.
		#doubleClick:	sent when the mouse goes up, down, and up again all within DoubleClickTime.
		#doubleClickTimeout:  sent when the mouse does not have a doubleClick within DoubleClickTime.
		#startDrag:	sent when the mouse moves more than 10 pixels from evt's position within DoubleClickTime.
	Note that mouseMove: and mouseUp: events are not sent to aMorph until it becomes the mouse focus,
	which is typically done by aMorph in its click:, doubleClick:, or drag: methods."
	
	^self waitForClicksOrDrag: aMorph event: evt selectors: #( #click: #doubleClick: #doubleClickTimeout: #startDrag:) threshold: 10

]

{ #category : #events }
OSMorphicWindow >> windowCloseRequested [
	
	self close
]

{ #category : #iterating }
OSMorphicWindow >> withAllOwnersDo: aBlock [
	"Evaluate aBlock with the receiver and all of its owners"
	aBlock value: self.
]

{ #category : #accessing }
OSMorphicWindow >> world [
	^ self
]
