Class {
	#name : #TextEditionEvent,
	#superclass : #UserInputEvent,
	#instVars : [
		'text',
		'start',
		'length'
	],
	#category : #'Morphic-Core-Events'
}

{ #category : #accessing }
TextEditionEvent >> isTextEditionEvent [

	^true
]

{ #category : #accessing }
TextEditionEvent >> length [

	^ length
]

{ #category : #accessing }
TextEditionEvent >> length: anObject [

	length := anObject
]

{ #category : #accessing }
TextEditionEvent >> sentTo: anObject [

	^anObject handleTextEditionEvent: self
]

{ #category : #accessing }
TextEditionEvent >> start [

	^ start
]

{ #category : #accessing }
TextEditionEvent >> start: anObject [

	start := anObject
]

{ #category : #accessing }
TextEditionEvent >> text [

	^ text
]

{ #category : #accessing }
TextEditionEvent >> text: anObject [

	text := anObject
]
