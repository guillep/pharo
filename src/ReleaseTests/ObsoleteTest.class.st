"
Example class for ClassTest
"
Class {
	#name : 'ObsoleteTest',
	#superclass : 'AbstractEnvironmentTestCase',
	#instVars : [
		'classFactory'
	],
	#category : 'ReleaseTests-CleanCode',
	#package : 'ReleaseTests',
	#tag : 'CleanCode'
}

{ #category : 'accessing' }
ObsoleteTest class >> defaultTimeLimit [

	^ 30 seconds
]

{ #category : 'running' }
ObsoleteTest >> setUp [
	super setUp.
	"These tests are written to work on the global environment"
	testingEnvironment := Smalltalk globals.
	classFactory := ClassFactoryForTestCase environment: testingEnvironment
]

{ #category : 'running' }
ObsoleteTest >> tearDown [

	classFactory cleanUp.
	super tearDown
]
