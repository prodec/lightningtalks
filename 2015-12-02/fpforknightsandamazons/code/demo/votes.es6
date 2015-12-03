import _ from "lodash";
import R from "ramda";

let whoVotedForWhom = { John: "Alice", Bob: "Alice", Alice: "John", Julia: "Bob" };

let v = _.chain(whoVotedForWhom)
  .pairs()
  .reduce((votes, [voter, votee]) => {
    return _.extend(votes, { [votee]: (votes[votee] || []).concat([voter]) });
  }, {})
  .value();
console.log(v);

let v2 = R.pipe(R.toPairs, R.reduce((votes, [voter, votee]) => {
  return R.merge(votes, { [votee]: (votes[votee] || []).concat([voter]) });
}, {}))(whoVotedForWhom);
console.log(v2);
