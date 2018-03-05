"
I am an exception that notifies that a file already exists.
"
Class {
	#name : #FileAlreadyExists,
	#superclass : #FileException,
	#instVars : [
		'file'
	],
	#category : #'Files-Core'
}

{ #category : #'instance-creation' }
FileAlreadyExists class >> signalOnFile: aFile [ 
	
	self new
		file: aFile;
		signal
]

{ #category : #accessing }
FileAlreadyExists >> file [
	^ file
]

{ #category : #accessing }
FileAlreadyExists >> file: aFile [
	
	file := aFile
]

{ #category : #accessing }
FileAlreadyExists >> messageText [

	^ 'File already exists: ', file name
]
