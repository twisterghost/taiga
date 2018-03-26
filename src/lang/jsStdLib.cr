module Lang
  class StdLibProvider
    def initialize
    end

    def getStdLibString
      "
function arr() {return Array.prototype.slice.call(arguments);}
const arrSize = arr => arr.length;
const eq = (a, b) => a == b;
const taiga_if = (condition) => condition;
const arrShift = (arr) => arr.shift();
const arrPush = (arr, val) => arr.concat(val);
const arrGet = (arr, i) => arr[i];
const add = (a, b) => a + b;
const print = (stuff) => console.log(stuff);
"
    end
  end
end
