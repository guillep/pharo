Extension { #name : 'LinkedList' }

{ #category : '*Fuel-Core' }
LinkedList >> fuelAccept: aGeneralMapper [

	^ aGeneralMapper visitSimpleCollection: self
]
