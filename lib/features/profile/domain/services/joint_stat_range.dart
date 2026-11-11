/// Valid range of a per-joint mobility stat (`users/{uid}.stats`).
const double minJointStat = 1;
const double maxJointStat = 5;

/// Keeps a joint stat within [minJointStat, maxJointStat].
///
/// Some diagnosis questions offer options above 5 (the flexibility question
/// goes up to 6), and profiles saved before this limit may hold such values.
double clampJointStat(double value) =>
    value.clamp(minJointStat, maxJointStat).toDouble();
