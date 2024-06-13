package main

import (
	"fmt"
	"open-match.dev/open-match/pkg/pb"
)

// Generates profiles based on regions and room IDs for the Director.
func generateProfiles(regions []string, roomIDs []string) []*pb.MatchProfile {
	var profiles []*pb.MatchProfile

	for _, region := range regions {
		for _, roomID := range roomIDs {
			profile := &pb.MatchProfile{
				Name: fmt.Sprintf("profile_%s_%s", region, roomID),
				Pools: []*pb.Pool{
					{
						Name: "pool_mode_" + region + "_" + roomID,
						TagPresentFilters: []*pb.TagPresentFilter{
							{Tag: "mode.session"},
						},
						StringEqualsFilters: []*pb.StringEqualsFilter{
							{StringArg: "region", Value: region},
							{StringArg: "room", Value: roomID},
						},
					},
				},
			}
			profiles = append(profiles, profile)
		}
	}

	return profiles
}
