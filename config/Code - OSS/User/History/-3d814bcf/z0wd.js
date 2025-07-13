// greet('Max') - OK
// bark() - RefErr

function greet(name) {
    console.log('Hello,', name)
}

const bark = function () {
    console.log('WOOOOOAAAAAFFFF')
}

greet('Max')
bark()

console.log(typeof bark)

const arror = () => {
    console.log('MEOW!')
}

const pow2 = (num=1) => num ** 2

console.log([1, 2, 3, 4, 5].map((pow2)))
console.log([1, 2, 3, 4, 5].filter((n) => (n % 2)))

// rest operator
function sumAll(...all) {
    let res = 0;
    for (let n in all) {
        res += n
    }
    // return res

    return all.reduce((acc, n) => {
        return(acc += n)
    }, 0) // same
}

// замыкание
function createMember(name) {
    return function(lastName) {
        return (name + ' ' + lastName)
    }
}

const johnCreator = createMember('John')
console.log(johnCreator('Smith'))