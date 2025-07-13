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

delete person.arrow

const {firstName, lastName} = person

Object.keys(person).forEach(key => console.log(person[key]))


