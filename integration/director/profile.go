package main

import (
	"fmt"
	"open-match.dev/open-match/pkg/pb"
)

// Generates profiles based on regions and room IDs for the Director.
func generateProfiles(regions []string) []*pb.MatchProfile {
	var profiles []*pb.MatchProfile

	for _, region := range regions {
		profile := &pb.MatchProfile{
			Name: fmt.Sprintf("profile_%s", region),
			Pools: []*pb.Pool{
				{
					Name: "pool_mode_" + region,
					TagPresentFilters: []*pb.TagPresentFilter{
						{Tag: "mode.session"},
					},
					StringEqualsFilters: []*pb.StringEqualsFilter{
						{StringArg: "region", Value: region},
					},
				},
			},
		}
		profiles = append(profiles, profile)
	}

	return profiles
}
