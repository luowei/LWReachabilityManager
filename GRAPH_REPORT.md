# Graph Report - /Users/luowei/projects/libs/LWReachabilityManager  (2026-05-04)

## Corpus Check
- Corpus is ~9,516 words - fits in a single context window. You may not need a graph.

## Summary
- 90 nodes · 93 edges · 9 communities detected
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]

## God Nodes (most connected - your core abstractions)
1. `LWNetworkReachabilityManager` - 20 edges
2. `NetworkReachabilityObserver` - 8 edges
3. `LWAppDelegate` - 7 edges
4. `ExampleViewController` - 7 edges
5. `NetworkReachabilityStatus` - 6 edges
6. `ExampleViewModel` - 5 edges
7. `Tests` - 4 edges
8. `NetworkReachabilityModifier` - 4 edges
9. `View` - 4 edges
10. `APIReachabilityMonitor` - 4 edges

## Surprising Connections (you probably didn't know these)
- `ExampleViewModel` --inherits--> `ObservableObject`  [EXTRACTED]
  LWReachabilityManager_swift/Classes/LWReachabilityUsageExamples.swift →   _Bridges community 1 → community 3_

## Communities (14 total, 1 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.12
Nodes (11): LWNetworkReachabilityManager, -dealloc, -initWithReachability, -isReachable, -isReachableViaWiFi, -isReachableViaWWAN, -keyPathsForValuesAffectingValueForKey, -manager (+3 more)

### Community 1 - "Community 1"
Cohesion: 0.22
Nodes (3): APIReachabilityMonitor, NetworkReachabilityObserver, ObservableObject

### Community 2 - "Community 2"
Cohesion: 0.24
Nodes (7): DetailRow, NetworkReachabilityModifier, NetworkReachabilityStatusView, NetworkReachabilityStatusView_Previews, View, PreviewProvider, ViewModifier

### Community 3 - "Community 3"
Cohesion: 0.22
Nodes (4): ExampleSwiftUIView, ExampleViewModel, ExampleViewModifier, View

### Community 4 - "Community 4"
Cohesion: 0.25
Nodes (7): LWAppDelegate, -applicationDidBecomeActive, -applicationDidEnterBackground, -applicationdidFinishLaunchingWithOptions, -applicationWillEnterForeground, -applicationWillResignActive, -applicationWillTerminate

### Community 5 - "Community 5"
Cohesion: 0.25
Nodes (7): NetworkReachabilityStatus, notReachable, reachableViaWiFi, reachableViaWWAN, unknown, Notification.Name, Int

### Community 7 - "Community 7"
Cohesion: 0.4
Nodes (4): Tests, -setUp, -tearDown, -testExample

### Community 8 - "Community 8"
Cohesion: 0.5
Nodes (3): LWViewController, -didReceiveMemoryWarning, -viewDidLoad

## Knowledge Gaps
- **26 isolated node(s):** `-setUp`, `-tearDown`, `-testExample`, `-applicationdidFinishLaunchingWithOptions`, `-applicationWillResignActive` (+21 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `LWNetworkReachabilityManager` connect `Community 0` to `Community 5`?**
  _High betweenness centrality (0.081) - this node is a cross-community bridge._
- **Why does `ExampleViewController` connect `Community 6` to `Community 3`?**
  _High betweenness centrality (0.037) - this node is a cross-community bridge._
- **What connects `-setUp`, `-tearDown`, `-testExample` to the rest of the system?**
  _26 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.12 - nodes in this community are weakly interconnected._