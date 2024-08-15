
# MapKitDemo

This repo is a demo code for MapKit, showcasing the following features:
The demos implemented in UIKit:

- Lookaround
- LocalSearch
- MKDirections

The demos implemented in SwiftUI:

- MKMapItem.Identifier
- DetailSheet for a map item
- Map's overlay - MapCircle & MapPolygon
- Rendering routes on Map - MapPolyline & MKRoute

### UIKit cases:

This demo also shows how to use AI tools to assist in the development process during the live coding session in iOS@Taipei.
The demos were created in 4 steps:

- Initial state - listing the requirements prompts
- Adding comments about the tools in other files to inform the AI tool of the available tools
- 1st version - implementation with some assistance from AI tools
- 2nd version - business logic split and handled by the interactor and other objects

During the development of the demo code, I did not commit all steps.
However, you can review the code step by step with these 4 commits to see the important changes.

### SwiftUI cases:

- MKMapItem.Identifier:
    - `MapItemIdentifierDemoView`
    - The demo shows how to use `MKMapItem.Identifier` to easily retrieve a map item.
    - For the identifier of each map item of Apple, you can use this website to look up: https://developer.apple.com/maps/place-id-lookup/iPhoneURLScheme_Reference/MapLinks/MapLinks.html)

- DetailSheet for a map item:
    - `DetailSheetDemoView`
    - The demo shows 2 ways to present a detail sheet for a map item.
    - The map item detail sheet is not a part of the map, instead, you can display it from any kind of view.

- Map's overlay:
    - `SpotAreaDemoView`
    - Here we have 2 types of overlays: `MapCircle` and `MapPolygon`, and we can customize the appearance of the overlays.

    <table>
    <tr>
    <th>MKMapItem.Identifier</th>
    <th>DetailSheet for a map item</th>
    <th>Map's overlay</th>
    </tr>
    <tr>
    <td><video src=https://github.com/user-attachments/assets/78aa4221-1865-4392-814c-13a916e0802a width=300 /></td>
    <td><video src=https://github.com/user-attachments/assets/22cbb48b-8d80-4ed5-97f9-3b0ba5b40d33 width=300 /></td>
    <td><video src=https://github.com/user-attachments/assets/3bb6a68c-a619-46ff-9c2a-cb67c99bcfa3 width=300 /></td>
    </tr>
    </table>

- Map's overlay - MapPolyline: 
    - `RouteDemoView`
    - The demo shows how to render routes on the map with `MapPolyline` with the information from `MKRoute`.
    - Also, it includes the way to retrieve the route from the source to the destination by MKDirections.

    <table>
    <tr>
    <th>Get MKRoute using MKDirection</th>
    <th>Route style</th>
    <th>MapPolyline in 3D</th>
    </tr>
    <tr>
    <td><video src=https://github.com/user-attachments/assets/6007bd97-1b06-4ff5-b7ee-2d6fbc07a23b width=300 /></td>
    <td><video src=https://github.com/user-attachments/assets/4e6d7c7b-1de1-4546-8082-881f70c9505e width=300 /></td>
    <td><video src=https://github.com/user-attachments/assets/dbc517e6-6475-43bc-a4c3-3c8e25fe1720 width=300 /></td>
    </tr>
    </table>
