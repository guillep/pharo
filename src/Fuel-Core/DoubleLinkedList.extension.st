Extension { #name : 'DoubleLinkedList' }

{ #category : '*Fuel-Core' }
DoubleLinkedList >> fuelAccept: aGeneralMapper [

	^ aGeneralMapper visitSimpleCollection: self
]
