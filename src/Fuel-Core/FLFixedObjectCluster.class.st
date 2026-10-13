"
I am a generic cluster for objects without indexable variables.
"
Class {
	#name : 'FLFixedObjectCluster',
	#superclass : 'FLPointerObjectCluster',
	#category : 'Fuel-Core-Clusters',
	#package : 'Fuel-Core',
	#tag : 'Clusters'
}

{ #category : 'serialize/materialize' }
FLFixedObjectCluster >> materializeInstanceWith: aDecoder [

	^theClass fuelNew
]

{ #category : 'serialize/materialize' }
FLFixedObjectCluster >> serializeInstancesStepWith: anEncoder [
	"Do nothing. I know my objects have nothing to serialize in this step."
]

{ #category : 'as yet unclassified' }
FLFixedObjectCluster >> setAnalyzedClass: aClass [

	| blackList |
	"Fuel has been reviewed to prevent general serialization/deserialization of these types.
	They should use specific clusters that ensure safe serialization/deserialization."
	blackList := { DoubleLinkedList . LinkedList }.
	(blackList includes: aClass)
		ifTrue: [ FLConfigurationError signal: 'Cannot configure this generic cluster with the blacklisted class. Use the specialized cluster for: ', aClass name ].
	super setAnalyzedClass: aClass
]
