function existy(x) {
  return x != null;
}

function truthy(x) {
  return (x !== false) && existy(x);
}

function doWhen(cond, action) {
  if (truthy(cond)) {
    return action();
  } else {
    return undefined;
  }
}

function countBy(values, fn) {
  return values.reduce((counts, v) => {
    let tag = fn(v);

    if (truthy(counts[tag])) {
      counts[tag] += 1;
    } else {
      counts[tag] = 1;
    }

    return counts;
  }, {});
}

function toArray(iterable) {
  let out = [];

  for (let i = 0; i < iterable.length; i++) {
    out.push(iterable[i]);
  }

  return out;
}

function slice(array, begin, end) {
  let startAt = begin || 0,
      endAt   = end ? (end > array.length ? array.length : end) : array.length,
      acc     = [];

  for (let i = startAt; i < endAt; i++) {
    acc.push(array[i]);
  }

  return acc;
}

function first(array) {
  return array[0];
}

function rest(array) {
  return slice(array, 1);
}

function cat() {
  let head = first(arguments);

  if (existy(head)) {
    return head.concat.apply(head, rest(arguments));
  } else {
    return [];
  }
}

function construct(head, tail) {
  return cat([head], tail);
}

function isFunction(obj) {
  return typeof obj == "function";
}

export {
  existy,
  truthy,
  doWhen,
  countBy,
  toArray,
  first,
  rest,
  slice,
  cat,
  construct,
  isFunction
};
