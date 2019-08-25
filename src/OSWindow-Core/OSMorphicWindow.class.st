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
	#superclass : #OSWorldRenderer,
	#category : #'OSWindow-Core-Morphic'
}

{ #category : #compat }
OSMorphicWindow >> doActivate [

	(osWindow notNil and: [ osWindow isValid ])
		ifTrue: [ ^ self ].

	self open
]
