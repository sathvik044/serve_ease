import java.util.*;
class MyThread extends Thread {
    int n, m;

    // Constructor to initialize n and m
    MyThread(int n, int m) {
        this.n = n;
        this.m = m;
    }

    // Method to print first 'n' natural numbers
    void printNaturalNumbers(int n) {
        System.out.println("Printing first " + n + " natural numbers:");
        for (int i = 1; i <= n; i++) {
            System.out.print(i + " ");
        }
        System.out.println();
    }

    // Method to calculate sum of first 'm' natural numbers
    void sumNaturalNumbers(int m) {
        int sum = 0;
        for (int i = 1; i <= m; i++) {
            sum += i;
        }
        System.out.println("Sum of first " + m + " natural numbers: " + sum);
    }

    // run() method will call both methods with parameters
    public void run() {
        printNaturalNumbers(n);
        sumNaturalNumbers(m);
    }
}

 class Main {
    public static void main(String[] args) {
        // Create thread object with parameters (example: 5 and 10)
        MyThread t1 = new MyThread(5, 10);

        // Start the thread
        t1.start();
    }
}