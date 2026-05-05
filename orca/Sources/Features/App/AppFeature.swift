import ComposableArchitecture

@Reducer
struct AppFeature {
  @Dependency(\.authClient) var authClient
  @Dependency(\.courseClient) var courseClient
  @Dependency(\.courseCacheClient) var courseCacheClient
  @Dependency(\.studentIDClient) var studentIDClient
  @Dependency(\.studentIDStoreClient) var studentIDStoreClient
  @Dependency(\.watchCourseSyncClient) var watchCourseSyncClient
  @Dependency(\.widgetTimelineClient) var widgetTimelineClient

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .contentTask:
        return reduceContentTask(&state)

      case .coursesLoaded,
        .coursesFailed,
        .cacheSyncFailed:
        return reduceCourseResponse(&state, action)

      case .sessionCleared:
        return .none

      default:
        return reduceSession(&state, action)
      }
    }
  }
}
