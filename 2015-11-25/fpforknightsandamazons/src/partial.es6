import { construct } from "./prelude";

function partial1(fn, arg1) {
  return ((/* arguments */) => {
    let args = construct(arg1, arguments);
    return fn.apply(fn, args);
  });
}

function partial2(fn, arg1, arg2) {

}

export {
  partial1,
  partial2
};
