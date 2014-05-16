#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include "pbook.h"

static void gauselim ( double **a, double *b, int n, int *ipvt, int flag );
static int decomp ( double **a, int n, double *condptr, int *ipvt );
static void solve ( double **a, int n, double *b, int *ipvt );


void solveLinearSystem ( double **a, double *b_then_x, int n )
{
	int *indx;

	// solve the linear system ax=b ... the inputs are 
	// the nxn matrix a; the dimension n of the matrix;
	// and the vector b ... the solution x is returned
	// in the place of vector b (so this memory starts out as b
	// and finishes as x)

	if ( n < 1 ) { 
		exitOrException("\ndid not expect to solve a linear system with zero equations");
	}

	indx = new int [ n ];

	gauselim ( a, b_then_x, n, indx, 0 );

	delete [] indx;
}


static void gauselim ( double **a, double *b, int n, int *ipvt, int flag )
{
	// Gaussian elimination with partial pivoting.
	// gauselim solves ax=b and replaces b on output by the solution.
	// On output, the original values of both a and b are destroyed.
	//   
	// Translated by P.W.Wong from FORTRAN code in the following source:
	//    Computer Methods for Mathematical Computations
	//    G.E. Forsythe, M.A. Malcolm and C.B. Moler; Prentice-Hall, 1967.
	//
	// Altered by Dan Tretter to use new memory allocation routines.
	// Sept 19, 1994. 

	// Uses decomp() and solve() to solve linear systems of equations.
	// If flag == 0, then call both decomp and solve.
	// If flag == 1, then a and ipvt are assumed to have been processed
	// previously by decomp(), only solve() will be called.

    int erflag;
    double cond;

    if ( flag == 0 ) {

		erflag = decomp(a,n,&cond,ipvt);

		if (erflag != 0) {
		  exitOrException("\ngauselim: exact singularity detected in Gaussian elimination");
		}
		if ( cond == ( cond + 1.0 ) ) {
		  exitOrException("\ngauselim: matrix is singular to working precision");
		}
	}

    solve ( a, n, b, ipvt );
}


static int decomp ( double **a, int n, double *condptr, int *ipvt )
{
	// Decomposes a matrix a[0..n-1][0..n-1] by Gaussian elimination
	// and estimates the condition number of a.
	// Use solve() to compute solutions to linear systems.
	// On output **a contains an upper triangular matrix U
	// and a permuted version of a lower triangular matrix L
	// so that (permutation matrix*a)=L*U
  
	// *condptr is an estimate of the condition number of a.
	// if *condptr==*condptr+1, a is singular to working precision.

	// If exact singularity is detected, decomp returns the value 1.
	// Otherwise, it returns 0.

	// ipvt contains the pivot vector. It must not be changed if
	// solve is to be called multiple time for the solution of
	// multiple linear systems with the same a.
	// The determinant of a can be obtained on output by
	// det(a)=ipvt[n-1]*a[0][0]*a[1][1]*...*a[n-1][n-1]

    int i,j,k,nm1,kp1,kb,m;
    double ek,t,anorm,ynorm,znorm;
    double *work;

    ipvt[n-1] = 1;
    if ( n == 1 ) {
		if ( a[0][0] == 0.0 ) return ( 1 );
		else {
			*condptr = 1.0;
			return(0);
		}
    }

    nm1 = n - 1;
    /* compute 1-norm of a */
    anorm = 0.0;
    for ( j = 0; j < n; j++ ) {
		t = 0.0;
		for ( i = 0; i < n; i++ ) t += fabs ( a[i][j] );
		if ( t > anorm ) anorm = t;
    }
    /* Gaussian elimination with partial pivoting */
    for ( k = 0; k < nm1; k++ ) {
		kp1 = k + 1;
		/* find pivot */
		m = k;
		for (i=kp1;i<n;i++)
			if (fabs(a[i][k]) > fabs(a[m][k]))
			m = i;
		ipvt[k] = m;
		if (m != k)
			ipvt[n-1] = -ipvt[n-1];
		t = a[m][k];
		a[m][k] = a[k][k];
		a[k][k] = t;
		if ( t != 0.0 ) {
			/* Compute multipliers */
			for (i=kp1;i<n;i++) a[i][k] /= -t;
			/* Interchange and eliminate by columns */
			for ( j = kp1; j < n; j++ ) {
				t = a[m][j];
				a[m][j] = a[k][j];
				a[k][j] = t;
				if ( t != 0.0 ) {
					for (i=kp1;i<n;i++)
					a[i][j] += a[i][k] * t;
				}
			}
		}
    }

    /*
      cond = (1-norm of a)*(an estimate of 1-norm of a-inverse)
      estimate obtained by one step of inverse iteration for the small
      singular vector. This involves solving two systems of equations,
      (a-transpose)*y=e and a*z=y where e is a vector of +1 and -1
      chosen to cause growth in y.
      estimate = (1-norm of z)/(1-norm of y)
      */

    work = new double [ n ]; 
    /* solve (a-transpose)*y=e */
    for (k=0;k<n;k++)
    {
	t = 0.0;
	for (i=0;i<k;i++)
	    t += a[i][k] * work[i];
	ek = (t < 0.0) ? -1.0 : 1.0;
	if (a[k][k] == 0.0)	/* exact singularity detected */
	{
	    free((char *) work);
	    return(1);
	}
	work[k] = -(ek + t) / a[k][k];
    }
    for (kb=0;kb<nm1;kb++)
    {
	k = n - 2 - kb;
	t = 0.0;
	kp1 = k + 1;
	for (i=kp1;i<n;i++)
	    t += a[i][k] * work[k];
	work[k] = t;
	m = ipvt[k];
	if (m != k)
	{
	    t = work[m];
	    work[m] = work[k];
	    work[k] = t;
	}
    }
    ynorm = 0.0;
    for (i=0;i<n;i++)
	ynorm += fabs(work[i]);
    /* solve a*z=y */
    solve(a,n,work,ipvt);
    znorm = 0.0;
    for (i=0;i<n;i++)
	znorm += fabs(work[i]);
    /* estimate condition */
    *condptr = anorm * znorm / ynorm;
    if (*condptr < 1.0)
	*condptr = 1.0;
    delete [] work; 
    return(0);
}

static void solve ( double **a, int n, double *b, int *ipvt )
{
	// Solution of linear system a*x=b.
	// Do not use if decomp has detected singularity.

    int kb,nm1,i,k,m;
    double t;
    
    // forward elimination 
    nm1 = n - 1;
    for (k=0;k<nm1;k++)
    {
	m = ipvt[k];
	t = b[m];
	b[m] = b[k];
	b[k] = t;
	for (i=k+1;i<n;i++)
	    b[i] += a[i][k] * t;
    }

    // back substitution 
    for (kb=0;kb<nm1;kb++)
    {
	k = n - 1 - kb;
	b[k] /= a[k][k];
	t = -b[k];
	for (i=0;i<k;i++)
	    b[i] += a[i][k] * t;
    }
    b[0] = b[0] / a[0][0];
}

