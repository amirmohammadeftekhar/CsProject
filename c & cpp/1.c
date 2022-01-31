#include<stdio.h>
#include<math.h>

int main()
{
    int a[10][10], b[10][10], x[10], ratioa, ratiob;
    for(int i=0;i<10;i++) for(int j=0;j<10;j++) a[i][j] = b[i][j] = 1;
    int i,j,k,n;
    for(int i=0;i<10;i++){
        for(int j=0;j<10;j++){
            b[i][j] = 1;
        }
    }
    scanf("%d", &n);
    for(i=0;i<n;i++)
    {
        for(j=0;j<n;j++)
        {
            printf("a[%d][%d] = ",i,j);
            scanf("%d", &a[i][j]);
        }
    }
    for(i=0;i<n;i++)
    {
        for(j=0;j<n;j++)
        {
            if(i==j)
            {
                a[i][j+n] = 1;
            }
            else
            {
                a[i][j+n] = 0;
            }
        }
    }
    for(i=0;i<n;i++)
    {
        /* for(int ii=0;ii<n;ii++){ */
        /*     for(int jj=0;jj<2*n;jj++){ */
        /*         printf("%d", a[ii][jj]); */
        /*     } */
        /* } */
        /* for(int ii=0;ii<n;ii++){ */
        /*     for(int jj=0;jj<2*n;jj++){ */
        /*         printf("%d", b[ii][jj]); */
        /*     } */
        /* } */
        /* printf("\n"); */
        if(a[i][i] == 0)
        {
            printf("Mathematical Error!");
            return(0);
        }
        for(j=0;j<n;j++)
        {
            if(i!=j)
            {
                ratioa = a[j][i]*b[i][i];
                ratiob = a[i][i]*b[j][i];
                for(k=0;k<2*n;k++)
                {
                    a[j][k] = a[j][k]*ratiob*b[i][k] - ratioa*a[i][k]*b[j][k];
                    b[j][k] *= ratiob*b[i][k];
                    printf("!!!!\n");
                }
            }
        }
    }
    for(i=0;i<n;i++)
    {
        for(j=n;j<2*n;j++)
        {
            a[i][j]*=b[i][i];
            b[i][j]*=a[i][i];
        }
    }
    printf("\nInverse Matrix is:\n");
    for(i=0;i<n;i++)
    {
        for(j=n;j<2*n;j++)
        {
            printf("%0.3f\t",a[i][j]*1.0/b[i][j]);
        }
        printf("\n");
    }
    return(0);
}
