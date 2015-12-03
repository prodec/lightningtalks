import { toArray } from "./prelude";

function checker() {
  let validators = toArray(arguments);

  return (obj) => {
    return validators.reduce((errs, check) => {
      if (check(obj)) {
        return errs;
      } else {
        errs.push(check.message);

        return errs;
      }
    }, []);
  };
}

export { checker };
