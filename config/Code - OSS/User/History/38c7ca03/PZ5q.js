const number = 3
let name = 'Smith'

let currentYear = 2025
const birthday = 2006

let age = currentYear - birthday

console.log(age)
console.log(age == '19') // true
console.log(age === '19') // false

console.log(typeof 13.13)
console.log(typeof 1238731379231n)
console.log(typeof {'a' : 13})
console.log(null)
console.log(typeof NaN)
console.log(typeof undefined)
console.log(typeof Symbol('a'))

const myStatus = 'pending'

if (myStatus === 'pending') {
    console.log('smth')
} else {
    console.log('aboba')
}

