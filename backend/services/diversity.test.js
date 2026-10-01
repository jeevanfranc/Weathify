/* global jest, describe, test, beforeEach, expect*/


const service = require('./recommendationService');

describe('Diversity Filter for Recommendation Logic', () => {


    // test 1: normal/expected case
    test('Should return all songs if they are unique and within the limit', () => {
        const fakeSongs = [
            { id: 1, title: 'Song A', artist: 'Artist One'},
            { id: 2, title: 'Song B', artist: 'Artist Two'},
            { id: 3, title: 'Song C', artist: 'Artist Three'}
        ];

        const result = service.applyDiversityFilter(fakeSongs, 5)

        expect(result.length).toBe(3);
        expect(result).toEqual(fakeSongs);
    });

    //test 2: diversity case
    test('Should filter out a third song from the same artist', () => {
        const temp = [
            { id: 1, title: 'Song A', artist: 'Eminem'},
            { id: 2, title: 'Song B', artist: 'Eminem'},
            { id: 3, title: 'Song C', artist: 'Eminem'},
            { id: 4, title: 'Song D', artist: 'Drake'}
        ];

        const result = service.applyDiversityFilter(temp, 5);

        expect(result.length).toBe(3);
        expect(result).not.toContainEqual({ id: 3, title: 'Song C', artist: 'Eminem' });
        expect(result).toContainEqual({ id: 4, title: 'Song D', artist: 'Drake' });
    });

    //test 3: limit case
    test('Should cut off execution immediately when the limit is reached', () => {
        const fakeSongs = [
            { id: 1, title: 'Song A', artist: 'Artist 1' },
            { id: 2, title: 'Song B', artist: 'Artist 2' },
            { id: 3, title: 'Song C', artist: 'Artist 3' },
            { id: 4, title: 'Song D', artist: 'Artist 4' }
        ];

        const result = service.applyDiversityFilter(fakeSongs, 2);

        // Assert that even though 4 songs were provided, it caps strictly at the limit of 2
        expect(result.length).toBe(2);
        expect(result[0].id).toBe(1);
        expect(result[1].id).toBe(2);
    });


    //extreme case of empty parameters
    test('Should handle empty song arrays gracefully without crashing', () => {
        const result = service.applyDiversityFilter([],10)
        expect(result).toEqual([]);
    });
});