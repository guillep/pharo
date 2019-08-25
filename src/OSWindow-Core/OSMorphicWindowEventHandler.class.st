Class {
	#name : #OSMorphicWindowEventHandler,
	#superclass : #Object,
	#instVars : [
		'osMorphicWindow'
	],
	#category : #'OSWindow-Core-Morphic'
}

{ #category : #accessing }
OSMorphicWindowEventHandler >> osMorphicWindow [
	^ osMorphicWindow
]

{ #category : #accessing }
OSMorphicWindowEventHandler >> osMorphicWindow: anObject [
	osMorphicWindow := anObject
]

{ #category : #'event-handling' }
OSMorphicWindowEventHandler >> windowCloseEvent: aWindowEvent [ 

	osMorphicWindow close
]

{ #category : #'event-handling' }
OSMorphicWindowEventHandler >> windowEvent: aWindowEvent [
	
	aWindowEvent type = #windowClose ifTrue: [ self windowCloseEvent: aWindowEvent ]
]
