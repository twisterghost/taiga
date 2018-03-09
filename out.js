
const arr = () => [];
const arrSize = arr => arr.length;
const eq = (a, b) => a == b;
const taiga_if = (condition) => condition;
const arrShift = (arr) => arr.shift();
const arrPush = (arr, val) => arr.concat(val);
const arrGet = (arr, i) => arr[i];
const add = (a, b) => a + b;
const print = (stuff) => console.log(stuff);
      
const main = () => {
let __taiga_retval__;
__taiga_retval__ = arr(1.0, 2.0, 3.0);
let data = _;
__taiga_retval__ = map(data, double);
__taiga_retval__ = print(__taiga_retval__);
return __taiga_retval__;
};

const map = (inputArr, func) => {
let __taiga_retval__;
__taiga_retval__ = arr();
__taiga_retval__ = _map(inputArr, func, __taiga_retval__);
return __taiga_retval__;
};

const _map = (inputArr, func, tempArr) => {
let __taiga_retval__;
__taiga_retval__ = arrSize(inputArr);
__taiga_retval__ = eq(__taiga_retval__, 0.0);
__taiga_retval__ = taiga_if(__taiga_retval__, return, tempArr);
__taiga_retval__ = arrShift(inputArr);
__taiga_retval__ = func(__taiga_retval__);
__taiga_retval__ = arrPush(tempArr, __taiga_retval__);
__taiga_retval__ = _map(inputArr, func, __taiga_retval__);
return __taiga_retval__;
};

const reduce = (inputArr, reducer, collector) => {
let __taiga_retval__;
__taiga_retval__ = _reduce(inputArr, reducer, collector, 0.0);
return __taiga_retval__;
};

const reduce_sub = (inputArr, reducer, collector, index) => {
let __taiga_retval__;
__taiga_retval__ = arrSize(inputArr);
__taiga_retval__ = eq(__taiga_retval__, index);
__taiga_retval__ = taiga_if(__taiga_retval__, return, collector);
__taiga_retval__ = arrGet(inputArr, index);
__taiga_retval__ = reducer(__taiga_retval__, collector);
let collector = _;
__taiga_retval__ = add(index, 1.0);
__taiga_retval__ = _reduce(inputArr, reducer, collector, __taiga_retval__);
return __taiga_retval__;
};

const double = (input) => {
let __taiga_retval__;
__taiga_retval__ = add(input, input);
return __taiga_retval__;
};
