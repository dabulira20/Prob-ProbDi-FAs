# APM1110: Probability and Probability Distributions
## Formative Assessment 5 — Solutions (Total: 30 Points)

---

## Problem 1: Discrete Random Variables [7 Points]

A discrete random variable $X$ has PMF:

$$P(X=x) = k(2x+1), \quad x = 1,2,3,4$$

### (a) Find the value of the constant $k$ [2 pts]

Since all probabilities must sum to 1:

$$k[(2(1)+1)+(2(2)+1)+(2(3)+1)+(2(4)+1)] = 1$$

$$k(3+5+7+9) = 1 \implies k(24) = 1 \implies \boxed{k = \dfrac{1}{24}}$$

The resulting probability distribution:

| $x$ | 1 | 2 | 3 | 4 |
|---|---|---|---|---|
| $P(X=x)$ | 3/24 | 5/24 | 7/24 | 9/24 |

### (b) Compute $E[X]$ and $Var(X)$ [3 pts]

$$E[X] = \sum x\,P(x) = 1\left(\tfrac{3}{24}\right)+2\left(\tfrac{5}{24}\right)+3\left(\tfrac{7}{24}\right)+4\left(\tfrac{9}{24}\right) = \frac{3+10+21+36}{24} = \frac{70}{24} = \frac{35}{12} \approx \boxed{2.9167}$$

$$E[X^2] = 1\left(\tfrac{3}{24}\right)+4\left(\tfrac{5}{24}\right)+9\left(\tfrac{7}{24}\right)+16\left(\tfrac{9}{24}\right) = \frac{3+20+63+144}{24} = \frac{230}{24} = \frac{115}{12} \approx 9.5833$$

$$Var(X) = E[X^2] - (E[X])^2 = \frac{115}{12} - \left(\frac{35}{12}\right)^2 = \frac{1380 - 1225}{144} = \frac{155}{144} \approx \boxed{1.0764}$$

### (c) Calculate $P(X \geq 3)$ [2 pts]

$$P(X \geq 3) = P(3) + P(4) = \frac{7}{24}+\frac{9}{24} = \frac{16}{24} = \frac{2}{3} \approx \boxed{0.6667}$$

---

## Problem 2: Binomial Distribution [7 Points]

$X \sim Binomial(n=20,\ p=0.08)$

### (a) $P(X = 2)$ [2 pts]

$$P(X=2) = \binom{20}{2}(0.08)^2(0.92)^{18} = 190 \times 0.0064 \times 0.222936 \approx \boxed{0.2711}$$

### (b) $P(X \geq 3)$ [3 pts]

$$P(X=0) = (0.92)^{20} \approx 0.1887$$
$$P(X=1) = \binom{20}{1}(0.08)^1(0.92)^{19} \approx 0.3282$$
$$P(X=2) \approx 0.2711$$

$$P(X \geq 3) = 1 - [P(0)+P(1)+P(2)] = 1 - 0.7879 \approx \boxed{0.2121}$$

### (c) Mean and standard deviation [2 pts]

$$\mu = np = 20(0.08) = \boxed{1.6000}$$

$$\sigma = \sqrt{np(1-p)} = \sqrt{20(0.08)(0.92)} = \sqrt{1.472} \approx \boxed{1.2133}$$

---

## Problem 3: Poisson Distribution [8 Points]

$\lambda = 4.5$ hits per minute

### (a) $P(X = 6)$ [2 pts]

$$P(X=6) = \frac{e^{-4.5}(4.5)^6}{6!} = \frac{(0.0111090)(8303.7656)}{720} \approx \boxed{0.1281}$$

### (b) $P(X \leq 2)$ [3 pts]

$$P(0) = e^{-4.5} \approx 0.011109$$
$$P(1) = e^{-4.5}(4.5) \approx 0.049990$$
$$P(2) = \frac{e^{-4.5}(4.5)^2}{2!} \approx 0.112479$$

$$P(X \leq 2) = 0.011109 + 0.049990 + 0.112479 \approx \boxed{0.1736}$$

### (c) $P(X > 10)$ over a 2-minute interval [3 pts]

For a 2-minute interval: $\lambda' = 4.5 \times 2 = 9$, so $X \sim Poisson(9)$.

| $k$ | $P(X=k)$ |
|---|---|
| 0 | 0.000123 |
| 1 | 0.001111 |
| 2 | 0.004998 |
| 3 | 0.014994 |
| 4 | 0.033737 |
| 5 | 0.060727 |
| 6 | 0.091090 |
| 7 | 0.117116 |
| 8 | 0.131756 |
| 9 | 0.131756 |
| 10 | 0.118580 |

$$P(X \leq 10) = \sum_{k=0}^{10}P(k) \approx 0.7060$$

$$P(X>10) = 1 - P(X \leq 10) = 1 - 0.7060 \approx \boxed{0.2940}$$

---

## Problem 4: Continuous Probability & Normal Distribution [8 Points]

$X \sim N(\mu = 120,\ \sigma = 15)$ milliseconds

### (a) $P(X > 135)$ [2 pts]

$$Z = \frac{135-120}{15} = 1.00$$

$$P(X>135) = 1 - \Phi(1.00) = 1 - 0.8413 = \boxed{0.1587}$$

### (b) $P(100 < X < 130)$ [3 pts]

$$Z_1 = \frac{100-120}{15} = -1.3333, \qquad Z_2 = \frac{130-120}{15} = 0.6667$$

$$\Phi(0.6667) \approx 0.7475, \qquad \Phi(-1.3333) \approx 0.0912$$

$$P(100<X<130) = 0.7475 - 0.0912 \approx \boxed{0.6563}$$

### (c) 95th percentile [3 pts]

The $z$-score corresponding to the 95th percentile is $z_{0.95} = 1.6449$.

$$X_{0.95} = \mu + z\sigma = 120 + 1.6449(15) = 120 + 24.6735 \approx \boxed{144.6735 \text{ ms}}$$

---

*Prepared for APM1110: Probability and Probability Distributions — Formative Assessment 5*
