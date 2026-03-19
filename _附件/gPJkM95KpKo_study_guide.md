# Advancing Go Garbage Collection: The Green Tea Approach

This study guide explores the evolution of the Go garbage collector (GC), focusing on a new technique called "Green Tea." It outlines the transition from object-oriented graph floods to a page-oriented scanning strategy designed to better align with modern CPU microarchitecture.

---

## 1. Fundamentals of Go Garbage Collection

The Go garbage collector is a mechanism designed to automatically reclaim and reuse heap memory that is no longer in use by a program. Its operations primarily involve two entities: **objects** (Go values on the heap) and **pointers** (memory addresses referring to those objects).

### The Mark-Sweep Algorithm
Go utilizes a "tracing" garbage collector that implements the Mark-Sweep algorithm. This process can be understood as a graph traversal where objects are nodes and pointers are edges.

*   **Mark Phase:** The collector starts from a well-defined set of "roots" (such as global and local variables) and performs a graph flood algorithm (similar to depth-first or breadth-first search). Every reachable object is marked as "visited" or "seen."
*   **Sweep Phase:** Any object not visited during the mark phase is considered unreachable. The collector iterates through these unvisited nodes and marks their memory as free for the memory allocator.

### Traditional Implementation Characteristics
| Feature | Description |
| :--- | :--- |
| **Concurrency** | The algorithm runs concurrently with the program, managing a mutating graph. |
| **Parallelism** | The workload is sharded across multiple CPU cores to improve speed. |
| **Worklist Discipline** | Traditionally uses a Last-In, First-Out (LIFO) stack-based approach, resulting in a depth-first search pattern. |
| **Object-Centric** | The collector tracks and scans individual objects one by one as it finds them. |

---

## 2. Limitations of Traditional GC

While functionally sound, the traditional mark-sweep approach faces significant performance bottlenecks on modern hardware.

### The Microarchitecture Mismatch
The core issue is that the traditional graph flood is a poor fit for modern CPU design. Approximately 35% of marking time is spent waiting for the CPU to fetch memory.
*   **Irregular Access:** The collector frequently jumps between different pages and memory locations, preventing the CPU from reaching high speeds.
*   **Cache Inefficiency:** CPU caches are optimized for nearby or recently accessed memory. Because the graph flood follows pointers that may point anywhere in the heap, it frequently misses the cache, leading to fetches from main memory that are up to 100 times slower.
*   **Dependency Chains:** Each bit of work in a graph flood is small and highly dependent on the previous bit, preventing the CPU from issuing multiple memory requests asynchronously.

### Hardware Challenges
*   **NUMA (Non-Uniform Memory Access):** Memory is often associated with specific subsets of CPU cores; accessing memory outside those subsets is slower.
*   **Bandwidth Constraints:** As the number of CPU cores increases, the relative number of memory requests each core can submit decreases, leading to contention.
*   **Underutilized Hardware:** Traditional marking cannot easily leverage vector instructions or SIMD (Single Instruction, Multiple Data) hardware.

---

## 3. The Green Tea Innovation

"Green Tea" represents a shift in strategy from tracking individual objects to tracking **memory pages**.

### Key Principles
1.  **Page-Oriented Scanning:** Instead of scanning objects individually, the collector scans entire pages.
2.  **Page-Level Worklists:** The worklist tracks pages rather than individual objects.
3.  **Local Metadata:** Marking and scanning status are tracked locally on each page.

### Metadata and the "Scanned" Bit
Green Tea introduces a second bit of metadata for every object slot in a page.
*   **Scene Bit:** Indicates the object has been reached via a pointer (similar to the traditional GC).
*   **Scanned Bit:** Indicates the object's own pointers have been processed.
The difference between these two bits tells the collector exactly which objects within a page need attention during a scan.

### The Shift to FIFO
Unlike the traditional LIFO stack, Green Tea uses a **First-In, First-Out (FIFO) queue** for its worklist.
*   **Accumulation:** By using a queue, the collector allows "seen" objects to accumulate on a page while it sits in the worklist.
*   **Batch Processing:** When a page is finally taken off the worklist, the collector can scan multiple objects in that page in a single pass, following the memory's natural order.

---

## 4. Hardware Optimization and Results

### Vector Acceleration (SIMD)
Green Tea enables the use of vector hardware by standardizing the metadata format. Because a page has a fixed number of slots, its metadata (seen and scanned bits) can often fit into two 512-bit registers. 
*   **Requirements:** Requires modern x86 hardware, such as AMD Zen4 or Intel Ice Lake, and specific bit manipulation instructions.
*   **Efficiency:** This allows the CPU to process page metadata much faster than the traditional approach.

### Performance Impact
| Metric | Improvement |
| :--- | :--- |
| **General CPU Cost Reduction** | 10% to 40% (Modal improvement of 10%) |
| **Vector Acceleration Bonus** | Approximately 10% additional reduction when applicable |
| **Scalability** | Smaller worklists lead to less contention and fewer stalls across threads. |

### Limitations and Mitigation
*   **Sparse Pages:** Some workloads might only have one object to scan per page. This can be slower than the traditional method due to the overhead of tracking pages.
*   **Fast Path:** The Go runtime includes a fast path for pages with only a single object to scan to eliminate these regressions.

---

## 5. Short-Answer Practice Questions

1.  **What is the primary purpose of the "Scanned" bit in the Green Tea algorithm?**
    *   *Answer:* It tracks whether an object's pointers have been walked. When combined with the "Seen" bit, it identifies which objects within a page still need to be scanned.

2.  **How does the use of a FIFO queue benefit the Green Tea scanning process?**
    *   *Answer:* It allows the collector to be "lazy," letting multiple objects on the same page be marked as "seen" before the page is processed. This enables batch scanning of objects in memory order.

3.  **Why is the traditional graph flood compared to "driving through city streets"?**
    *   *Answer:* Because the CPU cannot see far ahead; it must constantly slow down for turns (pointers) and stop for traffic lights (memory fetches), preventing it from utilizing its full processing speed.

4.  **At what density does page scanning begin to yield significant improvements?**
    *   *Answer:* Even at relatively low densities, such as scanning only 2% of a page at a time, the technique can provide significant performance gains.

5.  **What environment variable is used to enable Green Tea in Go 1.25?**
    *   *Answer:* `GOEXPERIMENT=greenteagc`

---

## 6. Essay Prompts for Deeper Exploration

1.  **Analyze the relationship between memory locality and garbage collection performance.** Discuss how Green Tea improves locality compared to the traditional mark-sweep algorithm and why this matters for modern CPU caches.
2.  **Evaluate the trade-offs of moving from an object-oriented to a page-oriented GC strategy.** Consider scenarios where Green Tea might underperform and describe the mechanisms the Go team implemented to mitigate these risks.
3.  **Discuss the impact of hardware evolution on software design as seen in the development of Green Tea.** How do features like SIMD, NUMA, and memory bandwidth constraints dictate the necessity of new algorithms in the Go runtime?

---

## 7. Glossary of Terms

*   **Green Tea:** A page-oriented garbage collection scanning strategy for the Go runtime.
*   **Heap:** The area of memory where Go values (objects) are allocated when their lifetime cannot be determined by the compiler.
*   **Mark-Sweep:** A two-phase garbage collection algorithm that identifies reachable objects and then reclaims the memory of unreachable ones.
*   **NUMA (Non-Uniform Memory Access):** A computer memory design where the memory access time depends on the memory location relative to the processor.
*   **Objects:** Go values whose underlying memory is allocated from the heap.
*   **Pointers:** Memory addresses that refer to Go values; used by the GC to trace reachability.
*   **Roots:** The starting points for the GC graph flood, such as global variables and local variables on the stack.
*   **Scanning:** The process of walking the pointers within an object to find other reachable objects.
*   **SIMD (Single Instruction, Multiple Data):** A type of parallel computing that allows one instruction to process multiple data points simultaneously, often using vector hardware.
*   **Sweep Phase:** The second stage of GC where unvisited memory is returned to the allocator.
*   **Worklist:** A data structure (stack or queue) used by the GC to keep track of objects or pages that need to be processed.