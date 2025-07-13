const person = {
	firstName: 'Dimka',
	lastName: 'Panov',
	age: '6',
	lichess: 'DimonPanov',
	isChild: true,
    'complex key' : 'smth',
    ['key_' + 1 + 2] : 42,
	sayMeow() {
		console.log('MEEEEEEEEEOOOOOW')
	},
    arrow: () => console.log('Hello from arrow func'),
}

console.log(person)



