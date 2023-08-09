# OCE_iGEM_Modeling

## What is this

This is the modeling part of our iGEM project. The whole project is ongoing right now, stay tuned.

This repo is only for recording and for fun.

## Where we are right now

Now, we have finished some part and are working on several things. Check out the TODO list!

## TODO

1. Draw the path of whole project, including the chemical reaction and gene regulation.
2. Modeling the formaldehyde operon and the related formaldehyde degradation process.
3. Modeling the formaldehyde sensor part.
4. Modeling the algae/e.coli coculture system.
5. Modeling the hardware.

### Task 1: path

This will go through the whole project. And this is what we have done now.

### Task 2: Modeling of HCHO operon/degradation

Ongoing.

### Task 3: Modeling of the HCHO sensor

Here are the results.

![F-T](Graph/F-T.jpg)
![S-F](Graph/S-F.jpg)

Generally speaking, we select the data that are collected:

1. after some time such that the system is stable.
2. at the concentration of HCHO will not disable the sensor(e.coli).

Then we use the processed data to fit to the equation:

$S=S_{min}+(S_{max}-S_{min})\times\frac{[F]^n}{K_m^n+[F]^n}$

and here is the result:

| Parameters | Estimate | Std. error | t value | P                |
|------------|----------|------------|---------|------------------|
| K_m        | 60.8330  | 5.1320     | 11.85   | 2.9× 10^(-5) *** |
| n          | 1.8250   | 0.2699     | 6.76    | 2.5× 10^(-3) **  |

![fit](Graph/fit-S-F-Hill.jpg)

### Task 4: coculture system

Well, a bit hard.

This may be split into some sub-tasks.

1. Modeling the photosynthesis part, which responsible for sucrose production.
2. Modeling the transformation of sucrose to glucose/fructose.
3. Modeling the the growth of the culture.